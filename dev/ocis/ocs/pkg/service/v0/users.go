package svc

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	accountsmsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/accounts/v0"
	accountssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/accounts/v0"

	storemsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/store/v0"
	storesvc "github.com/owncloud/ocis/protogen/gen/ocis/services/store/v0"

	"github.com/asim/go-micro/plugins/client/grpc/v4"
	revauser "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	rpcv1beta1 "github.com/cs3org/go-cs3apis/cs3/rpc/v1beta1"
	provider "github.com/cs3org/go-cs3apis/cs3/storage/provider/v1beta1"
	typesv1beta1 "github.com/cs3org/go-cs3apis/cs3/types/v1beta1"
	"github.com/cs3org/reva/v2/pkg/auth/scope"
	revactx "github.com/cs3org/reva/v2/pkg/ctx"
	"github.com/cs3org/reva/v2/pkg/rgrpc/todo/pool"
	"github.com/cs3org/reva/v2/pkg/token/manager/jwt"
	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/owncloud/ocis/ocs/pkg/service/v0/data"
	"github.com/owncloud/ocis/ocs/pkg/service/v0/response"
	ocstracing "github.com/owncloud/ocis/ocs/pkg/tracing"
	"github.com/pkg/errors"
	merrors "go-micro.dev/v4/errors"
	"google.golang.org/genproto/protobuf/field_mask"
	"google.golang.org/grpc/metadata"
	"google.golang.org/protobuf/types/known/fieldmaskpb"
)

// GetSelf returns the currently logged in user
func (o Ocs) GetSelf(w http.ResponseWriter, r *http.Request) {
	var account *accountsmsg.Account
	var err error
	u, ok := revactx.ContextGetUser(r.Context())
	if !ok || u.Id == nil || u.Id.OpaqueId == "" {
		o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "user is missing an id"))
		return
	}

	account, err = o.getAccountService().GetAccount(r.Context(), &accountssvc.GetAccountRequest{
		Id: u.Id.OpaqueId,
	})

	if err != nil {
		merr := merrors.FromError(err)
		// TODO(someone) this fix is in place because if the user backend (PROXY_ACCOUNT_BACKEND_TYPE) is set to, for instance,
		// cs3, we cannot count with the accounts service.
		if u != nil {
			d := &data.User{
				UserID:            u.Username,
				DisplayName:       u.DisplayName,
				LegacyDisplayName: u.DisplayName,
				Email:             u.Mail,
				UIDNumber:         u.UidNumber,
				GIDNumber:         u.GidNumber,
			}
			o.mustRender(w, r, response.DataRender(d))
			return
		}
		o.logger.Error().Err(merr).Interface("user", u).Msg("could not get account for user")
		return
	}

	// remove password from log if it is set
	if account.PasswordProfile != nil {
		account.PasswordProfile.Password = ""
	}
	o.logger.Debug().Interface("account", account).Msg("got user")

	d := &data.User{
		UserID:            account.OnPremisesSamAccountName,
		DisplayName:       account.DisplayName,
		LegacyDisplayName: account.DisplayName,
		Email:             account.Mail,
		UIDNumber:         account.UidNumber,
		GIDNumber:         account.GidNumber,
		// TODO hide enabled flag or it might get rendered as false
	}
	o.mustRender(w, r, response.DataRender(d))
}

// GetUser returns the user with the given userid
func (o Ocs) GetUser(w http.ResponseWriter, r *http.Request) {
	userid := chi.URLParam(r, "userid")
	userid, err := url.PathUnescape(userid)
	if err != nil {
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
	}
	var account *accountsmsg.Account

	switch {
	case userid == "":
		o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "missing user in context"))
	case o.config.AccountBackend == "accounts":
		account, err = o.fetchAccountByUsername(r.Context(), userid)
	case o.config.AccountBackend == "cs3":
		account, err = o.fetchAccountFromCS3Backend(r.Context(), userid)
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, data.MessageUserNotFound))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(merr).Str("userid", userid).Msg("could not get account for user")
		return
	}

	// remove password from log if it is set
	if account.PasswordProfile != nil {
		account.PasswordProfile.Password = ""
	}
	o.logger.Debug().Interface("account", account).Msg("got user")

	// mimic the oc10 bool as string for the user enabled property
	var enabled string
	if account.AccountEnabled {
		enabled = "true"
	} else {
		enabled = "false"
	}

	d := &data.User{
		UserID:            account.OnPremisesSamAccountName,
		DisplayName:       account.DisplayName,
		LegacyDisplayName: account.DisplayName,
		Email:             account.Mail,
		UIDNumber:         account.UidNumber,
		GIDNumber:         account.GidNumber,
		Enabled:           enabled, // TODO include in response only when admin?
		// TODO query storage registry for free space? of home storage, maybe...
		Quota: &data.Quota{
			Free:       2840756224000,
			Used:       5059416668,
			Total:      2845815640668,
			Relative:   0.18,
			Definition: "default",
		},
	}

	_, span := ocstracing.TraceProvider.
		Tracer("ocs").
		Start(r.Context(), "GetUser")
	defer span.End()

	o.mustRender(w, r, response.DataRender(d))
}

// AddUser creates a new user account
func (o Ocs) AddUser(w http.ResponseWriter, r *http.Request) {
	userid := r.PostFormValue("userid")
	password := r.PostFormValue("password")
	displayname := r.PostFormValue("displayname")
	email := r.PostFormValue("email")
	uid := r.PostFormValue("uidnumber")
	gid := r.PostFormValue("gidnumber")

	var uidNumber, gidNumber int64
	var err error

	if uid != "" {
		uidNumber, err = strconv.ParseInt(uid, 10, 64)
		if err != nil {
			o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "Cannot use the uidnumber provided"))
			o.logger.Error().Err(err).Str("userid", userid).Msg("Cannot use the uidnumber provided")
			return
		}
	}
	if gid != "" {
		gidNumber, err = strconv.ParseInt(gid, 10, 64)
		if err != nil {
			o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "Cannot use the gidnumber provided"))
			o.logger.Error().Err(err).Str("userid", userid).Msg("Cannot use the gidnumber provided")
			return
		}
	}
	if strings.TrimSpace(password) == "" {
		o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "empty password not allowed"))
		o.logger.Error().Str("userid", userid).Msg("empty password not allowed")
		return
	}

	// fallbacks
	/* TODO decide if we want to make these fallbacks. Keep in mind:
	- oCIS requires a preferred_name and email
	*/
	if displayname == "" {
		displayname = userid
	}

	newAccount := &accountsmsg.Account{
		Id:                       uuid.New().String(),
		DisplayName:              displayname,
		PreferredName:            userid,
		OnPremisesSamAccountName: userid,
		PasswordProfile: &accountsmsg.PasswordProfile{
			Password: password,
		},
		Mail:           email,
		AccountEnabled: true,
	}

	if uidNumber != 0 {
		newAccount.UidNumber = uidNumber
	}

	if gidNumber != 0 {
		newAccount.GidNumber = gidNumber
	}

	var account *accountsmsg.Account

	switch o.config.AccountBackend {
	case "accounts":
		account, err = o.getAccountService().CreateAccount(r.Context(), &accountssvc.CreateAccountRequest{
			Account: newAccount,
		})
	case "cs3":
		o.logger.Fatal().Msg("cs3 backend doesn't support adding users")
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		merr := merrors.FromError(err)
		switch merr.Code {
		case http.StatusBadRequest:
			o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, merr.Detail))
		case http.StatusConflict:
			if response.APIVersion(r.Context()) == "2" {
				// it seems the application framework sets the ocs status code to the httpstatus code, which affects the provisioning api
				// see https://github.com/owncloud/core/blob/b9ff4c93e051c94adfb301545098ae627e52ef76/lib/public/AppFramework/OCSController.php#L142-L150
				o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, merr.Detail))
			} else {
				o.mustRender(w, r, response.ErrRender(data.MetaInvalidInput.StatusCode, merr.Detail))
			}
		default:
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("userid", userid).Msg("could not add user")
		// TODO check error if account already existed
		return
	}

	// remove password from log if it is set
	if account.PasswordProfile != nil {
		account.PasswordProfile.Password = ""
	}
	o.logger.Debug().Interface("account", account).Msg("added user")

	// mimic the oc10 bool as string for the user enabled property
	var enabled string
	if account.AccountEnabled {
		enabled = "true"
	} else {
		enabled = "false"
	}
	o.mustRender(w, r, response.DataRender(&data.User{
		UserID:            account.OnPremisesSamAccountName,
		DisplayName:       account.DisplayName,
		LegacyDisplayName: account.DisplayName,
		Email:             account.Mail,
		UIDNumber:         account.UidNumber,
		GIDNumber:         account.GidNumber,
		Enabled:           enabled,
	}))
}

// EditUser creates a new user account
func (o Ocs) EditUser(w http.ResponseWriter, r *http.Request) {
	userid := chi.URLParam(r, "userid")
	userid, err := url.PathUnescape(userid)
	if err != nil {
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
	}

	var account *accountsmsg.Account
	switch o.config.AccountBackend {
	case "accounts":
		account, err = o.fetchAccountByUsername(r.Context(), userid)
	case "cs3":
		o.logger.Fatal().Msg("cs3 backend doesn't support editing users")
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, data.MessageUserNotFound))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("userid", userid).Msg("could not edit user")
		return
	}

	req := accountssvc.UpdateAccountRequest{
		Account: &accountsmsg.Account{
			Id: account.Id,
		},
	}
	key := r.PostFormValue("key")
	value := r.PostFormValue("value")

	switch key {
	case "email":
		req.Account.Mail = value
		req.UpdateMask = &fieldmaskpb.FieldMask{Paths: []string{"Mail"}}
	case "username":
		req.Account.PreferredName = value
		req.Account.OnPremisesSamAccountName = value
		req.UpdateMask = &fieldmaskpb.FieldMask{Paths: []string{"PreferredName", "OnPremisesSamAccountName"}}
	case "password":
		req.Account.PasswordProfile = &accountsmsg.PasswordProfile{
			Password: value,
		}
		req.UpdateMask = &fieldmaskpb.FieldMask{Paths: []string{"PasswordProfile.Password"}}
	case "displayname", "display":
		req.Account.DisplayName = value
		req.UpdateMask = &fieldmaskpb.FieldMask{Paths: []string{"DisplayName"}}
	default:
		// https://github.com/owncloud/core/blob/24b7fa1d2604a208582055309a5638dbd9bda1d1/apps/provisioning_api/lib/Users.php#L321
		o.mustRender(w, r, response.ErrRender(103, "unknown key '"+key+"'"))
		return
	}

	account, err = o.getAccountService().UpdateAccount(r.Context(), &req)
	if err != nil {
		merr := merrors.FromError(err)
		switch merr.Code {
		case http.StatusBadRequest:
			o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, merr.Detail))
		default:
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("account_id", req.Account.Id).Str("user_id", userid).Msg("could not edit user")
		return
	}

	// remove password from log if it is set
	if account.PasswordProfile != nil {
		account.PasswordProfile.Password = ""
	}

	o.logger.Debug().Interface("account", account).Msg("updated user")
	o.mustRender(w, r, response.DataRender(struct{}{}))
}

// DeleteUser deletes a user
func (o Ocs) DeleteUser(w http.ResponseWriter, r *http.Request) {
	userid := chi.URLParam(r, "userid")
	userid, err := url.PathUnescape(userid)
	if err != nil {
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
	}

	var account *accountsmsg.Account
	switch o.config.AccountBackend {
	case "accounts":
		account, err = o.fetchAccountByUsername(r.Context(), userid)
	case "cs3":
		o.logger.Fatal().Msg("cs3 backend doesn't support deleting users")
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, data.MessageUserNotFound))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("userid", userid).Msg("could not delete user")
		return
	}

	if o.config.Reva.Address != "" && o.config.StorageUsersDriver != "owncloud" {
		t, err := o.mintTokenForUser(r.Context(), account)
		if err != nil {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, errors.Wrap(err, "error minting token").Error()))
			return
		}

		ctx := metadata.AppendToOutgoingContext(r.Context(), revactx.TokenHeader, t)

		gwc, err := pool.GetGatewayServiceClient(o.config.Reva.Address)
		if err != nil {
			o.logger.Error().Err(err).Msg("error securing a connection to Reva gateway")
		}

		lsRes, err := gwc.ListStorageSpaces(ctx, &provider.ListStorageSpacesRequest{
			Filters: []*provider.ListStorageSpacesRequest_Filter{
				{
					Type: provider.ListStorageSpacesRequest_Filter_TYPE_OWNER,
					Term: &provider.ListStorageSpacesRequest_Filter_Owner{
						Owner: &revauser.UserId{
							Idp:      o.config.IdentityManagement.Address,
							OpaqueId: account.Id,
						},
					},
				},
			},
		})
		if err != nil {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, errors.Wrap(err, "could not list owned personal spaces").Error()))
			return
		}

		if lsRes.Status.Code != rpcv1beta1.Code_CODE_OK {
			o.logger.Error().
				Interface("status", lsRes.Status).
				Msg("DeleteUser: could not list personal spaces")
			return
		}

		for _, space := range lsRes.StorageSpaces {
			dsRes, err := gwc.DeleteStorageSpace(ctx, &provider.DeleteStorageSpaceRequest{
				Id: space.Id,
			})
			if err != nil {
				o.logger.Error().Err(err).Msg("DeleteUser: could not make delete space request")
				continue
			}
			if dsRes.Status.Code != rpcv1beta1.Code_CODE_OK && dsRes.Status.Code != rpcv1beta1.Code_CODE_NOT_FOUND {
				o.logger.Error().
					Interface("status", dsRes.Status).
					Msg("DeleteUser: could not delete space")
				continue
			}
		}
		lsRes, err = gwc.ListStorageSpaces(ctx, &provider.ListStorageSpacesRequest{
			Filters: []*provider.ListStorageSpacesRequest_Filter{
				{
					Type: provider.ListStorageSpacesRequest_Filter_TYPE_OWNER,
					Term: &provider.ListStorageSpacesRequest_Filter_Owner{
						Owner: &revauser.UserId{
							Idp:      o.config.IdentityManagement.Address,
							OpaqueId: account.Id,
						},
					},
				},
			},
		})
		if err != nil {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, errors.Wrap(err, "could not list owned personal spaces").Error()))
			return
		}

		if lsRes.Status.Code != rpcv1beta1.Code_CODE_OK {
			o.logger.Error().
				Interface("status", lsRes.Status).
				Msg("DeleteUser: could not list personal spaces")
			return
		}
		for _, space := range lsRes.StorageSpaces {
			dsRes, err := gwc.DeleteStorageSpace(ctx, &provider.DeleteStorageSpaceRequest{
				Opaque: &typesv1beta1.Opaque{
					Map: map[string]*typesv1beta1.OpaqueEntry{
						"purge": {},
					},
				},
				Id: space.Id,
			})
			if err != nil {
				o.logger.Error().Err(err).Msg("DeleteUser: could not make delete space request")
				continue
			}
			if dsRes.Status.Code != rpcv1beta1.Code_CODE_OK && dsRes.Status.Code != rpcv1beta1.Code_CODE_NOT_FOUND {
				o.logger.Error().
					Interface("status", dsRes.Status).
					Msg("DeleteUser: could not delete space")
				continue
			}
		}
	}

	req := accountssvc.DeleteAccountRequest{
		Id: account.Id,
	}

	_, err = o.getAccountService().DeleteAccount(r.Context(), &req)
	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, data.MessageUserNotFound))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("userid", req.Id).Msg("could not delete user")
		return
	}

	o.logger.Debug().Str("userid", req.Id).Msg("deleted user")
	o.mustRender(w, r, response.DataRender(struct{}{}))
}

// TODO(refs) this to ocis-pkg ... we are minting tokens all over the place ... or use a service? ... like reva?
func (o Ocs) mintTokenForUser(ctx context.Context, account *accountsmsg.Account) (string, error) {
	tm, _ := jwt.New(map[string]interface{}{
		"secret":  o.config.TokenManager.JWTSecret,
		"expires": int64(24 * 60 * 60),
	})

	u := &revauser.User{
		Id: &revauser.UserId{
			OpaqueId: account.Id,
			Idp:      o.config.IdentityManagement.Address,
		},
		Groups:    []string{},
		UidNumber: account.UidNumber,
		GidNumber: account.GidNumber,
	}
	s, err := scope.AddOwnerScope(nil)
	if err != nil {
		return "", err
	}
	return tm.MintToken(ctx, u, s)
}

// EnableUser enables a user
func (o Ocs) EnableUser(w http.ResponseWriter, r *http.Request) {
	userid := chi.URLParam(r, "userid")
	userid, err := url.PathUnescape(userid)
	if err != nil {
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
	}

	var account *accountsmsg.Account
	switch o.config.AccountBackend {
	case "accounts":
		account, err = o.fetchAccountByUsername(r.Context(), userid)
	case "cs3":
		o.logger.Fatal().Msg("cs3 backend doesn't support enabling users")
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, data.MessageUserNotFound))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("userid", userid).Msg("could not enable user")
		return
	}

	account.AccountEnabled = true

	req := accountssvc.UpdateAccountRequest{
		Account: account,
		UpdateMask: &field_mask.FieldMask{
			Paths: []string{"AccountEnabled"},
		},
	}

	_, err = o.getAccountService().UpdateAccount(r.Context(), &req)
	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, "The requested account could not be found"))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("account_id", account.Id).Msg("could not enable account")
		return
	}

	o.logger.Debug().Str("account_id", account.Id).Msg("enabled user")
	o.mustRender(w, r, response.DataRender(struct{}{}))
}

// DisableUser disables a user
func (o Ocs) DisableUser(w http.ResponseWriter, r *http.Request) {
	userid := chi.URLParam(r, "userid")
	userid, err := url.PathUnescape(userid)
	if err != nil {
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
	}

	var account *accountsmsg.Account
	switch o.config.AccountBackend {
	case "accounts":
		account, err = o.fetchAccountByUsername(r.Context(), userid)
	case "cs3":
		o.logger.Fatal().Msg("cs3 backend doesn't support disabling users")
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, data.MessageUserNotFound))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("userid", userid).Msg("could not disable user")
		return
	}

	account.AccountEnabled = false

	req := accountssvc.UpdateAccountRequest{
		Account: account,
		UpdateMask: &field_mask.FieldMask{
			Paths: []string{"AccountEnabled"},
		},
	}

	_, err = o.getAccountService().UpdateAccount(r.Context(), &req)
	if err != nil {
		merr := merrors.FromError(err)
		if merr.Code == http.StatusNotFound {
			o.mustRender(w, r, response.ErrRender(data.MetaNotFound.StatusCode, "The requested account could not be found"))
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, err.Error()))
		}
		o.logger.Error().Err(err).Str("account_id", account.Id).Msg("could not disable account")
		return
	}

	o.logger.Debug().Str("account_id", account.Id).Msg("disabled user")
	o.mustRender(w, r, response.DataRender(struct{}{}))
}

// GetSigningKey returns the signing key for the current user. It will create it on the fly if it does not exist
// The signing key is part of the user settings and is used by the proxy to authenticate requests
// Currently, the username is used as the OC-Credential
func (o Ocs) GetSigningKey(w http.ResponseWriter, r *http.Request) {
	u, ok := revactx.ContextGetUser(r.Context())
	if !ok {
		//o.logger.Error().Msg("missing user in context")
		o.mustRender(w, r, response.ErrRender(data.MetaBadRequest.StatusCode, "missing user in context"))
		return
	}

	// use the user's UUID
	userID := u.Id.OpaqueId

	c := storesvc.NewStoreService("com.owncloud.api.store", grpc.NewClient())
	res, err := c.Read(r.Context(), &storesvc.ReadRequest{
		Options: &storemsg.ReadOptions{
			Database: "proxy",
			Table:    "signing-keys",
		},
		Key: userID,
	})
	if err == nil && len(res.Records) > 0 {
		o.mustRender(w, r, response.DataRender(&data.SigningKey{
			User:       userID,
			SigningKey: string(res.Records[0].Value),
		}))
		return
	}
	if err != nil {
		e := merrors.Parse(err.Error())
		if e.Code == http.StatusNotFound {
			// not found is ok, so we can continue and generate the key on the fly
		} else {
			o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, "error reading from store"))
			return
		}
	}

	// try creating it
	key := make([]byte, 64)
	_, err = rand.Read(key[:])
	if err != nil {
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, "could not generate signing key"))
		return
	}
	signingKey := hex.EncodeToString(key)

	_, err = c.Write(r.Context(), &storesvc.WriteRequest{
		Options: &storemsg.WriteOptions{
			Database: "proxy",
			Table:    "signing-keys",
		},
		Record: &storemsg.Record{
			Key:   userID,
			Value: []byte(signingKey),
			// TODO Expiry?
		},
	})

	if err != nil {
		//o.logger.Error().Err(err).Msg("error writing key")
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, "could not persist signing key"))
		return
	}

	o.mustRender(w, r, response.DataRender(&data.SigningKey{
		User:       userID,
		SigningKey: signingKey,
	}))
}

// ListUsers lists the users
func (o Ocs) ListUsers(w http.ResponseWriter, r *http.Request) {
	search := r.URL.Query().Get("search")
	query := ""
	if search != "" {
		query = fmt.Sprintf("on_premises_sam_account_name eq '%s'", escapeValue(search))
	}

	var res *accountssvc.ListAccountsResponse
	var err error
	switch o.config.AccountBackend {
	case "accounts":
		res, err = o.getAccountService().ListAccounts(r.Context(), &accountssvc.ListAccountsRequest{
			Query: query,
		})
	case "cs3":
		// TODO
		o.logger.Fatal().Msg("cs3 backend doesn't support listing users")
	default:
		o.logger.Fatal().Msgf("Invalid accounts backend type '%s'", o.config.AccountBackend)
	}

	if err != nil {
		o.logger.Err(err).Msg("could not list users")
		o.mustRender(w, r, response.ErrRender(data.MetaServerError.StatusCode, "could not list users"))
		return
	}

	users := make([]string, 0, len(res.Accounts))
	for i := range res.Accounts {
		users = append(users, res.Accounts[i].OnPremisesSamAccountName)
	}

	o.mustRender(w, r, response.DataRender(&data.Users{Users: users}))
}

// escapeValue escapes all special characters in the value
func escapeValue(value string) string {
	return strings.ReplaceAll(value, "'", "''")
}

func (o Ocs) fetchAccountByUsername(ctx context.Context, name string) (*accountsmsg.Account, error) {
	var res *accountssvc.ListAccountsResponse
	res, err := o.getAccountService().ListAccounts(ctx, &accountssvc.ListAccountsRequest{
		Query: fmt.Sprintf("on_premises_sam_account_name eq '%v'", escapeValue(name)),
	})
	if err != nil {
		return nil, err
	}
	if res != nil && len(res.Accounts) == 1 {
		return res.Accounts[0], nil
	}
	return nil, merrors.NotFound("", data.MessageUserNotFound)
}

func (o Ocs) fetchAccountFromCS3Backend(ctx context.Context, name string) (*accountsmsg.Account, error) {
	backend := o.getCS3Backend()
	u, _, err := backend.GetUserByClaims(ctx, "username", name, false)
	if err != nil {
		return nil, err
	}
	return &accountsmsg.Account{
		OnPremisesSamAccountName: u.Username,
		DisplayName:              u.DisplayName,
		Mail:                     u.Mail,
		UidNumber:                u.UidNumber,
		GidNumber:                u.GidNumber,
	}, nil
}
