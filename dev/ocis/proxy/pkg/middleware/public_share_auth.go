package middleware

import (
	"net/http"
	"strings"

	gateway "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
)

const (
	headerRevaAccessToken   = "x-access-token"
	headerShareToken        = "public-token"
	basicAuthPasswordPrefix = "password|"
	authenticationType      = "publicshares"
)

// PublicShareAuth ...
func PublicShareAuth(opts ...Option) func(next http.Handler) http.Handler {
	options := newOptions(opts...)
	logger := options.Logger

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			shareToken := r.Header.Get(headerShareToken)
			if shareToken == "" {
				shareToken = r.URL.Query().Get(headerShareToken)
			}

			// Currently we only want to authenticate app open request coming from public shares.
			if shareToken == "" {
				// Don't authenticate
				next.ServeHTTP(w, r)
				return
			}

			var sharePassword string
			if signature := r.URL.Query().Get("signature"); signature != "" {
				expiration := r.URL.Query().Get("expiration")
				if expiration == "" {
					logger.Warn().Str("signature", signature).Msg("cannot do signature auth without the expiration")
					next.ServeHTTP(w, r)
					return
				}
				sharePassword = strings.Join([]string{"signature", signature, expiration}, "|")
			} else {
				// We can ignore the username since it is always set to "public" in public shares.
				_, password, ok := r.BasicAuth()

				sharePassword = basicAuthPasswordPrefix
				if ok {
					sharePassword += password
				}
			}

			authResp, err := options.RevaGatewayClient.Authenticate(r.Context(), &gateway.AuthenticateRequest{
				Type:         authenticationType,
				ClientId:     shareToken,
				ClientSecret: sharePassword,
			})

			if err != nil {
				logger.Debug().Err(err).Str("public_share_token", shareToken).Msg("could not authenticate public share")
				// try another middleware
				next.ServeHTTP(w, r)
				return
			}

			r.Header.Add(headerRevaAccessToken, authResp.Token)
			next.ServeHTTP(w, r)
		})
	}
}
