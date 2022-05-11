package middleware

import (
	"net/http"
	"net/url"

	revactx "github.com/cs3org/reva/v2/pkg/ctx"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/render"
	accounts "github.com/owncloud/ocis/accounts/pkg/service/v0"
	"github.com/owncloud/ocis/ocis-pkg/roles"
	"github.com/owncloud/ocis/ocs/pkg/service/v0/data"
	"github.com/owncloud/ocis/ocs/pkg/service/v0/response"
	settingsService "github.com/owncloud/ocis/settings/pkg/service/v0"
)

// RequireSelfOrAdmin middleware is used to require the requesting user to be an admin or the requested user himself
func RequireSelfOrAdmin(opts ...Option) func(next http.Handler) http.Handler {
	opt := newOptions(opts...)

	mustRender := func(w http.ResponseWriter, r *http.Request, renderer render.Renderer) {
		if err := render.Render(w, r, renderer); err != nil {
			opt.Logger.Err(err).Msgf("failed to write response for ocs request %s on %s", r.Method, r.URL)
		}
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

			u, ok := revactx.ContextGetUser(r.Context())
			if !ok {
				mustRender(w, r, response.ErrRender(data.MetaUnauthorized.StatusCode, "Unauthorized"))
				return
			}
			if u.Id == nil || u.Id.OpaqueId == "" {
				mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "user is missing an id"))
				return
			}
			// get roles from context
			roleIDs, ok := roles.ReadRoleIDsFromContext(r.Context())
			if !ok {
				opt.Logger.Debug().Str("userid", u.Id.OpaqueId).Msg("No roles in context, contacting settings service")
				var err error
				roleIDs, err = opt.RoleManager.FindRoleIDsForUser(r.Context(), u.Id.OpaqueId)
				if err != nil {
					opt.Logger.Err(err).Str("userid", u.Id.OpaqueId).Msg("failed to get roles for user")
					mustRender(w, r, response.ErrRender(data.MetaUnauthorized.StatusCode, "Unauthorized"))
					return
				}
				if len(roleIDs) == 0 {
					roleIDs = append(roleIDs, settingsService.BundleUUIDRoleUser, settingsService.SelfManagementPermissionID)
					// if roles are empty, assume we haven't seen the user before and assign a default user role. At least until
					// proper roles are provided. See https://github.com/owncloud/ocis/issues/1825 for more context.
					//return user, nil
				}
			}

			// check if account management permission is present in roles of the authenticated account
			if opt.RoleManager.FindPermissionByID(r.Context(), roleIDs, accounts.AccountManagementPermissionID) != nil {
				next.ServeHTTP(w, r)
				return
			}

			// check if self management permission is present in roles of the authenticated account
			if opt.RoleManager.FindPermissionByID(r.Context(), roleIDs, accounts.SelfManagementPermissionID) != nil {
				userid := chi.URLParam(r, "userid")
				var err error
				if userid, err = url.PathUnescape(userid); err != nil {
					mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "malformed username"))
				}

				if userid == "" || userid == u.Id.OpaqueId || userid == u.Username {
					next.ServeHTTP(w, r)
					return
				}
			}

			mustRender(w, r, response.ErrRender(data.MetaUnauthorized.StatusCode, "Unauthorized"))

		})
	}
}
