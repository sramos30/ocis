package service

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"testing"
	"time"

	accountsmsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/accounts/v0"
	accountssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/accounts/v0"

	"github.com/golang/protobuf/ptypes/empty"
	config "github.com/owncloud/ocis/accounts/pkg/config/defaults"
	olog "github.com/owncloud/ocis/ocis-pkg/log"
	"github.com/owncloud/ocis/ocis-pkg/middleware"
	"github.com/owncloud/ocis/ocis-pkg/roles"
	settingsmsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/settings/v0"
	settingssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/settings/v0"
	ssvc "github.com/owncloud/ocis/settings/pkg/service/v0"
	"github.com/stretchr/testify/assert"
	"go-micro.dev/v4/client"
	merrors "go-micro.dev/v4/errors"
	"go-micro.dev/v4/metadata"
)

const dataPath = "/tmp/ocis-accounts-tests"

var (
	roleServiceMock settingssvc.RoleService
	s               *Service
)

func init() {
	cfg := config.DefaultConfig()
	cfg.Repo.Backend = "disk"
	cfg.Repo.Disk.Path = dataPath
	logger := olog.NewLogger(olog.Color(true), olog.Pretty(true))
	roleServiceMock = buildRoleServiceMock()
	roleManager := roles.NewManager(
		roles.Logger(logger),
		roles.RoleService(roleServiceMock),
		roles.CacheTTL(time.Hour),
		roles.CacheSize(1024),
	)
	s, _ = New(
		Logger(logger),
		Config(cfg),
		RoleService(roleServiceMock),
		RoleManager(&roleManager),
	)
}

func setup() (teardown func()) {
	return func() {
		if err := os.RemoveAll(dataPath); err != nil {
			log.Printf("could not delete data root: %s", dataPath)
		} else {
			log.Println("data root deleted")
		}
	}
}

// TestPermissionsListAccounts checks permission handling on ListAccounts
func TestPermissionsListAccounts(t *testing.T) {
	var scenarios = []struct {
		name            string
		roleIDs         []string
		query           string
		permissionError error
	}{
		// TODO: remove this test when https://github.com/owncloud/ocis/accounts/pull/111 is merged
		// replace with two tests:
		// 1: "ListAccounts fails with 403 when roleIDs don't exist in context"
		// 2: "ListAccounts fails with 403 when ('no admin role in context' AND 'empty query')"
		{
			"ListAccounts succeeds when no roleIDs in context",
			nil,
			"",
			nil,
		},
		{
			"ListAccounts fails when no admin roleID in context",
			[]string{ssvc.BundleUUIDRoleUser, ssvc.BundleUUIDRoleGuest},
			"",
			merrors.Forbidden(s.id, "no permission for ListAccounts"),
		},
		{
			"ListAccounts succeeds when admin roleID in context",
			[]string{ssvc.BundleUUIDRoleAdmin},
			"",
			nil,
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			teardown := setup()
			defer teardown()

			ctx := buildTestCtx(t, scenario.roleIDs)
			request := &accountssvc.ListAccountsRequest{
				Query: scenario.query,
			}
			response := &accountssvc.ListAccountsResponse{}
			err := s.ListAccounts(ctx, request, response)
			if scenario.permissionError != nil {
				assert.Equal(t, scenario.permissionError, err)
			} else if err != nil {
				// we are only checking permissions here, so just check that the error code is not 403
				merr := merrors.FromError(err)
				assert.NotEqual(t, http.StatusForbidden, merr.GetCode())
			}
		})
	}
}

// TestPermissionsGetAccount checks permission handling on GetAccount
// TODO: remove this test function entirely, when https://github.com/owncloud/ocis/accounts/pull/111 is merged. GetAccount will not have permission checks for the time being.
func TestPermissionsGetAccount(t *testing.T) {
	var scenarios = []struct {
		name            string
		roleIDs         []string
		permissionError error
	}{
		{
			"GetAccount succeeds when no role IDs in context",
			nil,
			nil,
		},
		{
			"GetAccount fails when no admin roleID in context",
			[]string{ssvc.BundleUUIDRoleUser, ssvc.BundleUUIDRoleGuest},
			merrors.Forbidden(s.id, "no permission for GetAccount"),
		},
		{
			"GetAccount succeeds when admin roleID in context",
			[]string{ssvc.BundleUUIDRoleAdmin},
			nil,
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			teardown := setup()
			defer teardown()

			ctx := buildTestCtx(t, scenario.roleIDs)
			request := &accountssvc.GetAccountRequest{}
			response := &accountsmsg.Account{}
			err := s.GetAccount(ctx, request, response)
			if scenario.permissionError != nil {
				assert.Equal(t, scenario.permissionError, err)
			} else if err != nil {
				// we are only checking permissions here, so just check that the error code is not 403
				merr := merrors.FromError(err)
				assert.NotEqual(t, http.StatusForbidden, merr.GetCode())
			}
		})
	}
}

// TestPermissionsCreateAccount checks permission handling on CreateAccount
func TestPermissionsCreateAccount(t *testing.T) {
	var scenarios = []struct {
		name            string
		roleIDs         []string
		permissionError error
	}{
		// TODO: remove this test when https://github.com/owncloud/ocis/accounts/pull/111 is merged
		// replace with two tests:
		// 1: "CreateAccount fails with 403 when roleIDs don't exist in context"
		// 2: "CreateAccount fails with 403 when no admin role in context"
		{
			"CreateAccount succeeds when no role IDs in context",
			nil,
			nil,
		},
		{
			"CreateAccount fails when no admin roleID in context",
			[]string{ssvc.BundleUUIDRoleUser, ssvc.BundleUUIDRoleGuest},
			merrors.Forbidden(s.id, "no permission for CreateAccount"),
		},
		{
			"CreateAccount succeeds when admin roleID in context",
			[]string{ssvc.BundleUUIDRoleAdmin},
			nil,
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			teardown := setup()
			defer teardown()

			ctx := buildTestCtx(t, scenario.roleIDs)
			request := &accountssvc.CreateAccountRequest{}
			response := &accountsmsg.Account{}
			err := s.CreateAccount(ctx, request, response)
			if scenario.permissionError != nil {
				assert.Equal(t, scenario.permissionError, err)
			} else if err != nil {
				// we are only checking permissions here, so just check that the error code is not 403
				merr := merrors.FromError(err)
				assert.NotEqual(t, http.StatusForbidden, merr.GetCode())
			}
		})
	}
}

// TestPermissionsUpdateAccount checks permission handling on UpdateAccount
func TestPermissionsUpdateAccount(t *testing.T) {
	var scenarios = []struct {
		name            string
		roleIDs         []string
		permissionError error
	}{
		// TODO: remove this test when https://github.com/owncloud/ocis/accounts/pull/111 is merged
		// replace with two tests:
		// 1: "UpdateAccount fails with 403 when roleIDs don't exist in context"
		// 2: "UpdateAccount fails with 403 when no admin role in context"
		{
			"UpdateAccount succeeds when no role IDs in context",
			nil,
			nil,
		},
		{
			"UpdateAccount fails when no admin roleID in context",
			[]string{ssvc.BundleUUIDRoleUser, ssvc.BundleUUIDRoleGuest},
			merrors.Forbidden(s.id, "no permission for UpdateAccount"),
		},
		{
			"UpdateAccount succeeds when admin roleID in context",
			[]string{ssvc.BundleUUIDRoleAdmin},
			nil,
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			teardown := setup()
			defer teardown()

			ctx := buildTestCtx(t, scenario.roleIDs)
			request := &accountssvc.UpdateAccountRequest{}
			response := &accountsmsg.Account{}
			err := s.UpdateAccount(ctx, request, response)
			if scenario.permissionError != nil {
				assert.Equal(t, scenario.permissionError, err)
			} else if err != nil {
				// we are only checking permissions here, so just check that the error code is not 403
				merr := merrors.FromError(err)
				assert.NotEqual(t, http.StatusForbidden, merr.GetCode())
			}
		})
	}
}

// TestPermissionsDeleteAccount checks permission handling on DeleteAccount
func TestPermissionsDeleteAccount(t *testing.T) {
	var scenarios = []struct {
		name            string
		roleIDs         []string
		permissionError error
	}{
		// TODO: remove this test when https://github.com/owncloud/ocis/accounts/pull/111 is merged
		// replace with two tests:
		// 1: "DeleteAccount fails with 403 when roleIDs don't exist in context"
		// 2: "DeleteAccount fails with 403 when no admin role in context"
		{
			"DeleteAccount succeeds when no role IDs in context",
			nil,
			nil,
		},
		{
			"DeleteAccount fails when no admin roleID in context",
			[]string{ssvc.BundleUUIDRoleUser, ssvc.BundleUUIDRoleGuest},
			merrors.Forbidden(s.id, "no permission for DeleteAccount"),
		},
		{
			"DeleteAccount succeeds when admin roleID in context",
			[]string{ssvc.BundleUUIDRoleAdmin},
			nil,
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			teardown := setup()
			defer teardown()

			ctx := buildTestCtx(t, scenario.roleIDs)
			request := &accountssvc.DeleteAccountRequest{}
			response := &empty.Empty{}
			err := s.DeleteAccount(ctx, request, response)
			if scenario.permissionError != nil {
				assert.Equal(t, scenario.permissionError, err)
			} else if err != nil {
				// we are only checking permissions here, so just check that the error code is not 403
				merr := merrors.FromError(err)
				assert.NotEqual(t, http.StatusForbidden, merr.GetCode())
			}
		})
	}
}

func buildTestCtx(t *testing.T, roleIDs []string) context.Context {
	ctx := context.Background()
	if roleIDs != nil {
		roleIDs, err := json.Marshal(roleIDs)
		assert.NoError(t, err)
		ctx = metadata.Set(ctx, middleware.RoleIDs, string(roleIDs))
	}
	return ctx
}

func buildRoleServiceMock() settingssvc.RoleService {
	defaultRoles := map[string]*settingsmsg.Bundle{
		ssvc.BundleUUIDRoleAdmin: {
			Id:   ssvc.BundleUUIDRoleAdmin,
			Type: settingsmsg.Bundle_TYPE_ROLE,
			Resource: &settingsmsg.Resource{
				Type: settingsmsg.Resource_TYPE_SYSTEM,
			},
			Settings: []*settingsmsg.Setting{
				{
					Id: AccountManagementPermissionID,
				},
			},
		},
		ssvc.BundleUUIDRoleUser: {
			Id:   ssvc.BundleUUIDRoleUser,
			Type: settingsmsg.Bundle_TYPE_ROLE,
			Resource: &settingsmsg.Resource{
				Type: settingsmsg.Resource_TYPE_SYSTEM,
			},
			Settings: []*settingsmsg.Setting{},
		},
		ssvc.BundleUUIDRoleGuest: {
			Id:   ssvc.BundleUUIDRoleGuest,
			Type: settingsmsg.Bundle_TYPE_ROLE,
			Resource: &settingsmsg.Resource{
				Type: settingsmsg.Resource_TYPE_SYSTEM,
			},
			Settings: []*settingsmsg.Setting{},
		},
	}
	return settingssvc.MockRoleService{
		ListRolesFunc: func(ctx context.Context, req *settingssvc.ListBundlesRequest, opts ...client.CallOption) (res *settingssvc.ListBundlesResponse, err error) {
			payload := make([]*settingsmsg.Bundle, 0)
			for _, roleID := range req.BundleIds {
				if defaultRoles[roleID] != nil {
					payload = append(payload, defaultRoles[roleID])
				}
			}
			return &settingssvc.ListBundlesResponse{
				Bundles: payload,
			}, nil
		},
		AssignRoleToUserFunc: func(ctx context.Context, req *settingssvc.AssignRoleToUserRequest, opts ...client.CallOption) (res *settingssvc.AssignRoleToUserResponse, err error) {
			// mock can be empty. function is called during service start. actual role assignments not needed for the tests.
			return &settingssvc.AssignRoleToUserResponse{
				Assignment: &settingsmsg.UserRoleAssignment{},
			}, nil
		},
	}
}
