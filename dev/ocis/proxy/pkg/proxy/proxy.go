package proxy

import (
	"crypto/tls"
	"fmt"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"regexp"
	"strings"
	"time"

	chimiddleware "github.com/go-chi/chi/v5/middleware"

	"go.opentelemetry.io/otel/attribute"

	"github.com/owncloud/ocis/ocis-pkg/log"
	pkgtrace "github.com/owncloud/ocis/ocis-pkg/tracing"
	"github.com/owncloud/ocis/proxy/pkg/config"
	"github.com/owncloud/ocis/proxy/pkg/proxy/policy"
	proxytracing "github.com/owncloud/ocis/proxy/pkg/tracing"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/trace"
)

// MultiHostReverseProxy extends "httputil" to support multiple hosts with different policies
type MultiHostReverseProxy struct {
	httputil.ReverseProxy
	Directors      map[string]map[config.RouteType]map[string]func(req *http.Request)
	PolicySelector policy.Selector
	logger         log.Logger
	config         *config.Config
}

// NewMultiHostReverseProxy creates a new MultiHostReverseProxy
func NewMultiHostReverseProxy(opts ...Option) *MultiHostReverseProxy {
	options := newOptions(opts...)

	rp := &MultiHostReverseProxy{
		Directors: make(map[string]map[config.RouteType]map[string]func(req *http.Request)),
		logger:    options.Logger,
		config:    options.Config,
	}
	rp.Director = rp.directorSelectionDirector

	// equals http.DefaultTransport except TLSClientConfig
	rp.Transport = &http.Transport{
		Proxy: http.ProxyFromEnvironment,
		DialContext: (&net.Dialer{
			Timeout:   30 * time.Second,
			KeepAlive: 30 * time.Second,
			DualStack: true,
		}).DialContext,
		ForceAttemptHTTP2:     true,
		MaxIdleConns:          100,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: options.Config.InsecureBackends, //nolint:gosec
		},
	}

	if options.Config.PolicySelector == nil {
		firstPolicy := options.Config.Policies[0].Name
		rp.logger.Warn().Str("policy", firstPolicy).Msg("policy-selector not configured. Will always use first policy")
		options.Config.PolicySelector = &config.PolicySelector{
			Static: &config.StaticSelectorConf{
				Policy: firstPolicy,
			},
		}
	}

	rp.logger.Debug().
		Interface("selector_config", options.Config.PolicySelector).
		Msg("loading policy-selector")

	policySelector, err := policy.LoadSelector(options.Config.PolicySelector)
	if err != nil {
		rp.logger.Fatal().Err(err).Msg("Could not load policy-selector")
	}

	rp.PolicySelector = policySelector

	for _, pol := range options.Config.Policies {
		for _, route := range pol.Routes {
			rp.logger.Debug().Str("fwd: ", route.Endpoint)
			uri, err2 := url.Parse(route.Backend)
			if err2 != nil {
				rp.logger.
					Fatal(). // fail early on misconfiguration
					Err(err2).
					Str("backend", route.Backend).
					Msg("malformed url")
			}

			rp.AddHost(pol.Name, uri, route)
		}
	}

	return rp
}

func (p *MultiHostReverseProxy) directorSelectionDirector(r *http.Request) {
	pol, err := p.PolicySelector(r)
	if err != nil {
		p.logger.Error().Err(err).Msg("Error while selecting pol")
		return
	}

	if _, ok := p.Directors[pol]; !ok {
		p.logger.
			Error().
			Str("policy", pol).
			Msg("policy is not configured")
		return
	}

	// find matching director
	for _, rt := range config.RouteTypes {
		var handler func(string, url.URL) bool
		switch rt {
		case config.QueryRoute:
			handler = p.queryRouteMatcher
		case config.RegexRoute:
			handler = p.regexRouteMatcher
		case config.PrefixRoute:
			fallthrough
		default:
			handler = p.prefixRouteMatcher
		}
		for endpoint := range p.Directors[pol][rt] {
			if handler(endpoint, *r.URL) {

				p.logger.Debug().
					Str("policy", pol).
					Str("prefix", endpoint).
					Str("path", r.URL.Path).
					Str("routeType", string(rt)).
					Msg("director found")

				p.Directors[pol][rt][endpoint](r)
				return
			}
		}
	}

	// override default director with root. If any
	if p.Directors[pol][config.PrefixRoute]["/"] != nil {
		p.Directors[pol][config.PrefixRoute]["/"](r)
		return
	}

	p.logger.
		Warn().
		Str("policy", pol).
		Str("path", r.URL.Path).
		Msg("no director found")
}

func singleJoiningSlash(a, b string) string {
	aslash := strings.HasSuffix(a, "/")
	bslash := strings.HasPrefix(b, "/")
	switch {
	case aslash && bslash:
		return a + b[1:]
	case !aslash && !bslash:
		return a + "/" + b
	}
	return a + b
}

// AddHost undocumented
func (p *MultiHostReverseProxy) AddHost(policy string, target *url.URL, rt config.Route) {
	targetQuery := target.RawQuery
	if p.Directors[policy] == nil {
		p.Directors[policy] = make(map[config.RouteType]map[string]func(req *http.Request))
	}
	routeType := config.DefaultRouteType
	if rt.Type != "" {
		routeType = rt.Type
	}
	if p.Directors[policy][routeType] == nil {
		p.Directors[policy][routeType] = make(map[string]func(req *http.Request))
	}
	p.Directors[policy][routeType][rt.Endpoint] = func(req *http.Request) {
		req.URL.Scheme = target.Scheme
		req.URL.Host = target.Host
		// Apache deployments host addresses need to match on req.Host and req.URL.Host
		// see https://stackoverflow.com/questions/34745654/golang-reverseproxy-with-apache2-sni-hostname-error
		if rt.ApacheVHost {
			req.Host = target.Host
		}

		req.URL.Path = singleJoiningSlash(target.Path, req.URL.Path)
		if targetQuery == "" || req.URL.RawQuery == "" {
			req.URL.RawQuery = targetQuery + req.URL.RawQuery
		} else {
			req.URL.RawQuery = targetQuery + "&" + req.URL.RawQuery
		}
		if _, ok := req.Header["User-Agent"]; !ok {
			// explicitly disable User-Agent so it's not set to default value
			req.Header.Set("User-Agent", "")
		}
	}
}

func (p *MultiHostReverseProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var (
		ctx  = r.Context()
		span trace.Span
	)

	tracer := proxytracing.TraceProvider.Tracer("proxy")
	ctx, span = tracer.Start(ctx, fmt.Sprintf("%s %v", r.Method, r.URL.Path))
	defer span.End()

	span.SetAttributes(
		attribute.KeyValue{
			Key:   "x-request-id",
			Value: attribute.StringValue(chimiddleware.GetReqID(r.Context())),
		})

	pkgtrace.Propagator.Inject(ctx, propagation.HeaderCarrier(r.Header))

	p.ReverseProxy.ServeHTTP(w, r.WithContext(ctx))
}

func (p MultiHostReverseProxy) queryRouteMatcher(endpoint string, target url.URL) bool {
	u, _ := url.Parse(endpoint)
	if !strings.HasPrefix(target.Path, u.Path) || endpoint == "/" {
		return false
	}
	q := u.Query()
	if len(q) == 0 {
		return false
	}
	tq := target.Query()
	for k := range q {
		if q.Get(k) != tq.Get(k) {
			return false
		}
	}
	return true
}

func (p *MultiHostReverseProxy) regexRouteMatcher(pattern string, target url.URL) bool {
	matched, err := regexp.MatchString(pattern, target.String())
	if err != nil {
		p.logger.Warn().Err(err).Str("pattern", pattern).Msg("regex with pattern failed")
	}
	return matched
}

func (p *MultiHostReverseProxy) prefixRouteMatcher(prefix string, target url.URL) bool {
	return strings.HasPrefix(target.Path, prefix) && prefix != "/"
}
