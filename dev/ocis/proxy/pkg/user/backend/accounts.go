package backend

import (
	"context"
	"fmt"
	"net/http"
	"strings"

	accountsmsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/accounts/v0"
	accountssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/accounts/v0"

	cs3 "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	types "github.com/cs3org/go-cs3apis/cs3/types/v1beta1"
	"github.com/cs3org/reva/v2/pkg/auth/scope"
	"github.com/cs3org/reva/v2/pkg/token"
	"github.com/owncloud/ocis/ocis-pkg/log"
	"github.com/owncloud/ocis/ocis-pkg/oidc"
	settingssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/settings/v0"
)

// NewAccountsServiceUserBackend creates a user-provider which fetches users from the ocis accounts-service
func NewAccountsServiceUserBackend(ac accountssvc.AccountsService, rs settingssvc.RoleService, oidcISS string, tokenManager token.Manager, logger log.Logger) UserBackend {
	return &accountsServiceBackend{
		accountsClient:      ac,
		settingsRoleService: rs,
		OIDCIss:             oidcISS,
		tokenManager:        tokenManager,
		logger:              logger,
	}
}

type accountsServiceBackend struct {
	accountsClient      accountssvc.AccountsService
	settingsRoleService settingssvc.RoleService
	OIDCIss             string
	logger              log.Logger
	tokenManager        token.Manager
}

func (a accountsServiceBackend) GetUserByClaims(ctx context.Context, claim, value string, withRoles bool) (*cs3.User, string, error) {
	var account *accountsmsg.Account
	var status int
	var query string

	switch claim {
	case "mail":
		query = fmt.Sprintf("mail eq '%s'", strings.ReplaceAll(value, "'", "''"))
	case "username":
		query = fmt.Sprintf("preferred_name eq '%s'", strings.ReplaceAll(value, "'", "''"))
	case "id":
		query = fmt.Sprintf("id eq '%s'", strings.ReplaceAll(value, "'", "''"))
	default:
		return nil, "", fmt.Errorf("invalid user by claim lookup must be  'mail', 'username' or 'id")
	}

	account, status = a.getAccount(ctx, query)
	if status == http.StatusNotFound {
		return nil, "", ErrAccountNotFound
	}

	if status != 0 || account == nil {
		return nil, "", fmt.Errorf("could not get account, got status: %d", status)
	}

	if !account.AccountEnabled {
		return nil, "", ErrAccountDisabled
	}

	user := a.accountToUser(account)

	if withRoles {
		if err := injectRoles(ctx, user, a.settingsRoleService); err != nil {
			a.logger.Warn().Err(err).Msgf("Could not load roles... continuing without")
		}
	}

	token, err := a.generateToken(ctx, user)
	if err != nil {
		return nil, "", err
	}

	return user, token, nil

}

// Authenticate authenticates against the accounts services and returns the user on success
func (a *accountsServiceBackend) Authenticate(ctx context.Context, username string, password string) (*cs3.User, string, error) {
	query := fmt.Sprintf(
		"login eq '%s' and password eq '%s'",
		strings.ReplaceAll(username, "'", "''"),
		strings.ReplaceAll(password, "'", "''"),
	)
	account, status := a.getAccount(ctx, query)

	if status != 0 {
		return nil, "", fmt.Errorf("could not authenticate with username, password for user %s. Status: %d", username, status)
	}

	user := a.accountToUser(account)

	token, err := a.generateToken(ctx, user)
	if err != nil {
		return nil, "", err
	}

	if err := injectRoles(ctx, user, a.settingsRoleService); err != nil {
		a.logger.Warn().Err(err).Msgf("Could not load roles... continuing without")
	}

	return user, token, nil
}

func (a accountsServiceBackend) CreateUserFromClaims(ctx context.Context, claims map[string]interface{}) (*cs3.User, error) {
	req := &accountssvc.CreateAccountRequest{
		Account: &accountsmsg.Account{
			CreationType:   "LocalAccount",
			AccountEnabled: true,
		},
	}
	var ok bool
	if req.Account.DisplayName, ok = claims[oidc.Name].(string); !ok {
		a.logger.Debug().Msg("Missing name claim, trying displayname")
		if req.Account.DisplayName, ok = claims["displayname"].(string); !ok {
			a.logger.Debug().Msg("Missing displayname claim")
		}
	}
	if req.Account.PreferredName, ok = claims[oidc.PreferredUsername].(string); !ok {
		a.logger.Warn().Msg("Missing preferred_username claim, falling back to email")
		if req.Account.PreferredName, ok = claims[oidc.Email].(string); !ok {
			a.logger.Debug().Msg("Missing email claim as well")
		}
	}
	if req.Account.PreferredName != "" {
		// also use as on premises samaccount name
		req.Account.OnPremisesSamAccountName = req.Account.PreferredName
	}
	if req.Account.Mail, ok = claims[oidc.Email].(string); !ok {
		a.logger.Warn().Msg("Missing email claim")
	}
	created, err := a.accountsClient.CreateAccount(context.Background(), req)
	if err != nil {
		return nil, err
	}

	user := a.accountToUser(created)

	if err := injectRoles(ctx, user, a.settingsRoleService); err != nil {
		a.logger.Warn().Err(err).Msg("Could not load roles... continuing without")
	}

	return user, nil
}

func (a accountsServiceBackend) GetUserGroups(ctx context.Context, userID string) {
	panic("implement me")
}

// accountToUser converts an owncloud account struct to a reva user struct. In the proxy
// we work with the reva struct as a token can be minted from it.
func (a *accountsServiceBackend) accountToUser(account *accountsmsg.Account) *cs3.User {
	user := &cs3.User{
		Id: &cs3.UserId{
			OpaqueId: account.Id,
			Idp:      a.OIDCIss,
			Type:     cs3.UserType_USER_TYPE_PRIMARY, // TODO: once we have support for other user types, this needs to be inferred
		},
		Username:     account.OnPremisesSamAccountName,
		DisplayName:  account.DisplayName,
		Mail:         account.Mail,
		MailVerified: account.ExternalUserState == "" || account.ExternalUserState == "Accepted",
		Groups:       expandGroups(account),
		UidNumber:    account.UidNumber,
		GidNumber:    account.GidNumber,
	}
	return user
}

func (a *accountsServiceBackend) getAccount(ctx context.Context, query string) (account *accountsmsg.Account, status int) {
	resp, err := a.accountsClient.ListAccounts(ctx, &accountssvc.ListAccountsRequest{
		Query:    query,
		PageSize: 2,
	})

	if err != nil {
		a.logger.Error().Err(err).Str("query", query).Msgf("error fetching from accounts-service")
		status = http.StatusInternalServerError
		return
	}

	if len(resp.Accounts) <= 0 {
		a.logger.Error().Str("query", query).Msgf("account not found")
		status = http.StatusNotFound
		return
	}

	if len(resp.Accounts) > 1 {
		a.logger.Error().Str("query", query).Msgf("more than one account found, aborting")
		status = http.StatusForbidden
		return
	}

	account = resp.Accounts[0]
	return
}

func (a *accountsServiceBackend) generateToken(ctx context.Context, u *cs3.User) (string, error) {
	s, err := scope.AddOwnerScope(nil)
	if err != nil {
		a.logger.Error().Err(err).Msg("could not get owner scope")
		return "", err
	}

	token, err := a.tokenManager.MintToken(ctx, u, s)
	if err != nil {
		a.logger.Error().Err(err).Msg("could not mint token")
		return "", err
	}
	return token, nil
}

func expandGroups(account *accountsmsg.Account) []string {
	groups := make([]string, len(account.MemberOf))
	for i := range account.MemberOf {
		// reva needs the unix group name
		groups[i] = account.MemberOf[i].OnPremisesSamAccountName
	}
	return groups
}

// injectRoles adds roles from the roles-service to the user-struct by mutating an existing struct
func injectRoles(ctx context.Context, u *cs3.User, ss settingssvc.RoleService) error {
	roleIDs, err := loadRolesIDs(ctx, u.Id.OpaqueId, ss)
	if err != nil {
		return err
	}

	if len(roleIDs) == 0 {
		return nil
	}

	enc, err := encodeRoleIDs(roleIDs)
	if err != nil {
		return err
	}

	if u.Opaque == nil {
		u.Opaque = &types.Opaque{
			Map: map[string]*types.OpaqueEntry{
				"roles": enc,
			},
		}
	} else {
		u.Opaque.Map["roles"] = enc
	}

	return nil
}
