package command

import (
	"fmt"
	"os"
	"strconv"

	accountsmsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/accounts/v0"
	accountssvc "github.com/owncloud/ocis/protogen/gen/ocis/services/accounts/v0"

	"github.com/owncloud/ocis/accounts/pkg/flagset"

	"github.com/asim/go-micro/plugins/client/grpc/v4"
	tw "github.com/olekukonko/tablewriter"
	"github.com/owncloud/ocis/accounts/pkg/config"
	"github.com/urfave/cli/v2"
)

// InspectAccount command shows detailed information about a specific account.
func InspectAccount(cfg *config.Config) *cli.Command {
	return &cli.Command{
		Name:      "inspect",
		Usage:     "show detailed data on an existing account",
		Category:  "account management",
		ArgsUsage: "id",
		Flags:     flagset.InspectAccountWithConfig(cfg),
		Action: func(c *cli.Context) error {
			accServiceID := cfg.GRPC.Namespace + "." + cfg.Service.Name
			if c.NArg() != 1 {
				fmt.Println("Please provide a user-id")
				os.Exit(1)
			}

			uid := c.Args().First()
			accSvc := accountssvc.NewAccountsService(accServiceID, grpc.NewClient())
			acc, err := accSvc.GetAccount(c.Context, &accountssvc.GetAccountRequest{
				Id: uid,
			})

			if err != nil {
				fmt.Println(fmt.Errorf("could not view account %w", err))
				return err
			}

			buildAccountInspectTable(acc).Render()
			return nil
		}}
}

func buildAccountInspectTable(acc *accountsmsg.Account) *tw.Table {
	table := tw.NewWriter(os.Stdout)
	table.SetAutoMergeCells(true)
	table.AppendBulk([][]string{
		{"ID", acc.Id},
		{"Mail", acc.Mail},
		{"DisplayName", acc.DisplayName},
		{"PreferredName", acc.PreferredName},
		{"AccountEnabled", strconv.FormatBool(acc.AccountEnabled)},
		{"CreationType", acc.CreationType},
		{"CreatedDateTime", acc.CreatedDateTime.String()},
		{"Description", acc.Description},
		{"ExternalUserState", acc.ExternalUserState},
		{"UidNumber", fmt.Sprintf("%+d", acc.UidNumber)},
		{"GidNumber", fmt.Sprintf("%+d", acc.GidNumber)},
		{"IsResourceAccount", strconv.FormatBool(acc.IsResourceAccount)},
		{"OnPremisesDistinguishedName", acc.OnPremisesDistinguishedName},
		{"OnPremisesDomainName", acc.OnPremisesDomainName},
		{"OnPremisesImmutableId", acc.OnPremisesImmutableId},
		{"OnPremisesSamAccountName", acc.OnPremisesSamAccountName},
		{"OnPremisesSecurityIdentifier", acc.OnPremisesSecurityIdentifier},
		{"OnPremisesUserPrincipalName", acc.OnPremisesUserPrincipalName},
		{"RefreshTokenValidFromDateTime", acc.RefreshTokensValidFromDateTime.String()},
	})

	// Merged cell with group memberships
	for k := range acc.MemberOf {
		table.Append([]string{"MemberOf", acc.MemberOf[k].DisplayName})
	}

	return table
}
