package middleware

import (
	"errors"
	"net/http"

	"github.com/owncloud/ocis/proxy/pkg/user/backend"

	revactx "github.com/cs3org/reva/v2/pkg/ctx"
	"github.com/owncloud/ocis/ocis-pkg/log"
	"github.com/owncloud/ocis/ocis-pkg/oidc"
)

// AccountResolver provides a middleware which mints a jwt and adds it to the proxied request based
// on the oidc-claims
func AccountResolver(optionSetters ...Option) func(next http.Handler) http.Handler {
	options := newOptions(optionSetters...)
	logger := options.Logger

	return func(next http.Handler) http.Handler {
		return &accountResolver{
			next:                  next,
			logger:                logger,
			userProvider:          options.UserProvider,
			userOIDCClaim:         options.UserOIDCClaim,
			userCS3Claim:          options.UserCS3Claim,
			autoProvisionAccounts: options.AutoprovisionAccounts,
		}
	}
}

type accountResolver struct {
	next                  http.Handler
	logger                log.Logger
	userProvider          backend.UserBackend
	autoProvisionAccounts bool
	userOIDCClaim         string
	userCS3Claim          string
}

// TODO do not use the context to store values: https://medium.com/@cep21/how-to-correctly-use-context-context-in-go-1-7-8f2c0fafdf39
func (m accountResolver) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	ctx := req.Context()
	claims := oidc.FromContext(ctx)
	user, ok := revactx.ContextGetUser(ctx)
	token := ""
	// TODO what if an X-Access-Token is set? happens eg for download requests to the /data endpoint in the reva frontend

	if claims == nil && !ok {
		m.next.ServeHTTP(w, req)
		return
	}

	if user == nil && claims != nil {

		var err error
		var value string
		var ok bool
		if value, ok = claims[m.userOIDCClaim].(string); !ok || value == "" {
			m.logger.Error().Str("claim", m.userOIDCClaim).Interface("claims", claims).Msg("claim not set or empty")
			w.WriteHeader(http.StatusInternalServerError) // admin needs to make the idp send the right claim
			return
		}

		user, token, err = m.userProvider.GetUserByClaims(req.Context(), m.userCS3Claim, value, true)

		if errors.Is(err, backend.ErrAccountNotFound) {
			m.logger.Debug().Str("claim", m.userOIDCClaim).Str("value", value).Msg("User by claim not found")
			if !m.autoProvisionAccounts {
				m.logger.Debug().Interface("claims", claims).Msg("Autoprovisioning disabled")
				w.WriteHeader(http.StatusUnauthorized)
				return
			}
			m.logger.Debug().Interface("claims", claims).Msg("Autoprovisioning user")
			user, err = m.userProvider.CreateUserFromClaims(req.Context(), claims)
			// TODO instead of creating an account create a personal storage via the CS3 admin api?
			// see https://cs3org.github.io/cs3apis/#cs3.admin.user.v1beta1.CreateUserRequest
		}

		if errors.Is(err, backend.ErrAccountDisabled) {
			m.logger.Debug().Interface("claims", claims).Msg("Disabled")
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		if err != nil {
			m.logger.Error().Err(err).Msg("Could not get user by claim")
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		// add user to context for selectors
		ctx = revactx.ContextSetUser(ctx, user)
		req = req.WithContext(ctx)

		m.logger.Debug().Interface("claims", claims).Interface("user", user).Msg("associated claims with user")
	} else if user != nil {
		var err error
		_, token, err = m.userProvider.GetUserByClaims(req.Context(), "username", user.Username, true)

		if errors.Is(err, backend.ErrAccountDisabled) {
			m.logger.Debug().Interface("user", user).Msg("Disabled")
			w.WriteHeader(http.StatusUnauthorized)
			return
		}

		if err != nil {
			m.logger.Error().Err(err).Msg("Could not get user by claim")
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}

	req.Header.Set(revactx.TokenHeader, token)

	m.next.ServeHTTP(w, req)
}
