package svc

import (
	"bytes"
	"context"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/gorilla/mux"
	"github.com/libregraph/lico/bootstrap"
	dummyBackendSupport "github.com/libregraph/lico/bootstrap/backends/dummy"
	guestBackendSupport "github.com/libregraph/lico/bootstrap/backends/guest"
	kcBackendSupport "github.com/libregraph/lico/bootstrap/backends/kc"
	ldapBackendSupport "github.com/libregraph/lico/bootstrap/backends/ldap"
	licoconfig "github.com/libregraph/lico/config"
	"github.com/libregraph/lico/server"
	"github.com/owncloud/ocis/idp/pkg/assets"
	"github.com/owncloud/ocis/idp/pkg/config"
	"github.com/owncloud/ocis/idp/pkg/middleware"
	"github.com/owncloud/ocis/ocis-pkg/log"
	"stash.kopano.io/kgol/rndm"
)

// Service defines the extension handlers.
type Service interface {
	ServeHTTP(http.ResponseWriter, *http.Request)
}

// NewService returns a service implementation for Service.
func NewService(opts ...Option) Service {
	ctx := context.Background()
	options := newOptions(opts...)
	logger := options.Logger.Logger
	assetVFS := assets.New(
		assets.Logger(options.Logger),
		assets.Config(options.Config),
	)

	if err := initLicoInternalEnvVars(&options.Config.Ldap); err != nil {
		logger.Fatal().Err(err).Msg("could not initialize env vars")
	}

	if err := createConfigsIfNotExist(assetVFS, options.Config.IDP.IdentifierRegistrationConf, options.Config.IDP.Iss); err != nil {
		logger.Fatal().Err(err).Msg("could not create default config")
	}

	guestBackendSupport.MustRegister()
	ldapBackendSupport.MustRegister()
	dummyBackendSupport.MustRegister()
	kcBackendSupport.MustRegister()

	// https://play.golang.org/p/Mh8AVJCd593
	idpSettings := bootstrap.Settings(options.Config.IDP)

	bs, err := bootstrap.Boot(ctx, &idpSettings, &licoconfig.Config{
		Logger: log.LogrusWrap(logger),
	})

	if err != nil {
		logger.Fatal().Err(err).Msg("could not bootstrap idp")
	}

	managers := bs.Managers()
	routes := []server.WithRoutes{managers.Must("identity").(server.WithRoutes)}
	handlers := managers.Must("handler").(http.Handler)

	svc := IDP{
		logger: options.Logger,
		config: options.Config,
		assets: assetVFS,
	}

	svc.initMux(ctx, routes, handlers, options)

	return svc
}

func createConfigsIfNotExist(assets http.FileSystem, filePath, ocisURL string) error {

	folder := path.Dir(filePath)
	if _, err := os.Stat(folder); os.IsNotExist(err) {
		if err := os.MkdirAll(folder, 0700); err != nil {
			return err
		}
	}

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		defaultConf, err := assets.Open("/identifier-registration.yaml")
		if err != nil {
			return err
		}

		defer defaultConf.Close()

		confOnDisk, err := os.Create(filePath)
		if err != nil {
			return err
		}

		defer confOnDisk.Close()

		conf, err := ioutil.ReadAll(defaultConf)
		if err != nil {
			return err
		}

		// replace placeholder {{OCIS_URL}} with https://localhost:9200 / correct host
		conf = []byte(strings.ReplaceAll(string(conf), "{{OCIS_URL}}", strings.TrimRight(ocisURL, "/")))

		err = ioutil.WriteFile(filePath, conf, 0600)
		if err != nil {
			return err
		}
	}

	return nil

}

// Init vars which are currently not accessible via idp api
func initLicoInternalEnvVars(ldap *config.Ldap) error {
	var defaults = map[string]string{
		"LDAP_URI":                 ldap.URI,
		"LDAP_BINDDN":              ldap.BindDN,
		"LDAP_BINDPW":              ldap.BindPassword,
		"LDAP_BASEDN":              ldap.BaseDN,
		"LDAP_SCOPE":               ldap.Scope,
		"LDAP_LOGIN_ATTRIBUTE":     ldap.LoginAttribute,
		"LDAP_EMAIL_ATTRIBUTE":     ldap.EmailAttribute,
		"LDAP_NAME_ATTRIBUTE":      ldap.NameAttribute,
		"LDAP_UUID_ATTRIBUTE":      ldap.UUIDAttribute,
		"LDAP_UUID_ATTRIBUTE_TYPE": ldap.UUIDAttributeType,
		"LDAP_FILTER":              ldap.Filter,
	}

	for k, v := range defaults {
		if err := os.Setenv(k, v); err != nil {
			return fmt.Errorf("could not set env var %s=%s", k, v)
		}
	}

	return nil
}

// IDP defines implements the business logic for Service.
type IDP struct {
	logger log.Logger
	config *config.Config
	mux    *chi.Mux
	assets http.FileSystem
}

// initMux initializes the internal idp gorilla mux and mounts it in to a ocis chi-router
func (idp *IDP) initMux(ctx context.Context, r []server.WithRoutes, h http.Handler, options Options) {
	gm := mux.NewRouter()
	for _, route := range r {
		route.AddRoutes(ctx, gm)
	}

	// Delegate rest to provider which is also a handler.
	if h != nil {
		gm.NotFoundHandler = h
	}

	idp.mux = chi.NewMux()
	idp.mux.Use(options.Middleware...)

	idp.mux.Use(middleware.Static(
		"/signin/v1/",
		assets.New(
			assets.Logger(options.Logger),
			assets.Config(options.Config),
		),
	))

	// handle / | index.html with a template that needs to have the BASE_PREFIX replaced
	idp.mux.Get("/signin/v1/identifier", idp.Index())
	idp.mux.Get("/signin/v1/identifier/", idp.Index())
	idp.mux.Get("/signin/v1/identifier/index.html", idp.Index())

	idp.mux.Mount("/", gm)
}

// ServeHTTP implements the Service interface.
func (idp IDP) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	idp.mux.ServeHTTP(w, r)
}

// Index renders the static html with the
func (idp IDP) Index() http.HandlerFunc {

	f, err := idp.assets.Open("/identifier/index.html")
	if err != nil {
		idp.logger.Fatal().Err(err).Msg("Could not open index template")
	}

	template, err := ioutil.ReadAll(f)
	if err != nil {
		idp.logger.Fatal().Err(err).Msg("Could not read index template")
	}
	if err = f.Close(); err != nil {
		idp.logger.Fatal().Err(err).Msg("Could not close body")
	}

	// TODO add environment variable to make the path prefix configurable
	pp := "/signin/v1"
	indexHTML := bytes.Replace(template, []byte("__PATH_PREFIX__"), []byte(pp), 1)

	nonce := rndm.GenerateRandomString(32)
	indexHTML = bytes.Replace(indexHTML, []byte("__CSP_NONCE__"), []byte(nonce), 1)

	indexHTML = bytes.Replace(indexHTML, []byte("__PASSWORD_RESET_LINK__"), []byte(idp.config.Service.PasswordResetURI), 1)

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		if _, err := w.Write(indexHTML); err != nil {
			idp.logger.Error().Err(err).Msg("could not write to response writer")
		}
	})
}
