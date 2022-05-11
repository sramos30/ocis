package store

import (
	"log"
	"sync"
	"testing"

	olog "github.com/owncloud/ocis/ocis-pkg/log"
	settingsmsg "github.com/owncloud/ocis/protogen/gen/ocis/messages/settings/v0"
	"github.com/owncloud/ocis/settings/pkg/config/defaults"
	"github.com/stretchr/testify/require"
)

var (
	einstein = "a4d07560-a670-4be9-8d60-9b547751a208"
	//marie    = "3c054db3-eec1-4ca4-b985-bc56dcf560cb"

	s = &Store{
		Logger: logger,
		l:      &sync.Mutex{},
		cfg:    defaults.DefaultConfig(),
	}

	logger = olog.NewLogger(
		olog.Color(true),
		olog.Pretty(true),
		olog.Level("info"),
	)

	bundles = []*settingsmsg.Bundle{
		{
			Id:          "f36db5e6-a03c-40df-8413-711c67e40b47",
			Type:        settingsmsg.Bundle_TYPE_ROLE,
			DisplayName: "test role - reads | update",
			Name:        "TEST_ROLE",
			Extension:   "ocis-settings",
			Resource: &settingsmsg.Resource{
				Type: settingsmsg.Resource_TYPE_BUNDLE,
			},
			Settings: []*settingsmsg.Setting{
				{
					Id:   "updateID",
					Name: "update",
					Value: &settingsmsg.Setting_PermissionValue{
						PermissionValue: &settingsmsg.Permission{
							Operation: settingsmsg.Permission_OPERATION_UPDATE,
						},
					},
					Resource: &settingsmsg.Resource{
						Type: settingsmsg.Resource_TYPE_SETTING,
					},
				},
				{
					Id:   "readID",
					Name: "read",
					Value: &settingsmsg.Setting_PermissionValue{
						PermissionValue: &settingsmsg.Permission{
							Operation: settingsmsg.Permission_OPERATION_READ,
						},
					},
					Resource: &settingsmsg.Resource{
						Type: settingsmsg.Resource_TYPE_BUNDLE,
					},
				},
			},
		},
		{
			Id:          "44f1a664-0a7f-461a-b0be-5b59e46bbc7a",
			Type:        settingsmsg.Bundle_TYPE_ROLE,
			DisplayName: "another",
			Name:        "ANOTHER_TEST_ROLE",
			Extension:   "ocis-settings",
			Resource: &settingsmsg.Resource{
				Type: settingsmsg.Resource_TYPE_BUNDLE,
			},
			Settings: []*settingsmsg.Setting{
				{
					Id:   "readID",
					Name: "read",
					Value: &settingsmsg.Setting_PermissionValue{
						PermissionValue: &settingsmsg.Permission{
							Operation: settingsmsg.Permission_OPERATION_READ,
						},
					},
				},
			},
		},
	}
)

func init() {
	_ = NewMDC(s)
	setupRoles()
}

func setupRoles() {
	for i := range bundles {
		if _, err := s.WriteBundle(bundles[i]); err != nil {
			log.Fatal("error initializing ", err)
		}
	}
}

func TestAssignmentUniqueness(t *testing.T) {
	var scenarios = []struct {
		name       string
		userID     string
		firstRole  string
		secondRole string
	}{
		{
			"roles assignments",
			einstein,
			"f36db5e6-a03c-40df-8413-711c67e40b47",
			"44f1a664-0a7f-461a-b0be-5b59e46bbc7a",
		},
	}

	for _, scenario := range scenarios {
		scenario := scenario
		t.Run(scenario.name, func(t *testing.T) {
			firstAssignment, err := s.WriteRoleAssignment(scenario.userID, scenario.firstRole)
			require.NoError(t, err)
			require.Equal(t, firstAssignment.RoleId, scenario.firstRole)
			// TODO: check entry exists

			list, err := s.ListRoleAssignments(scenario.userID)
			require.NoError(t, err)
			require.Equal(t, 1, len(list))
			require.Equal(t, list[0].RoleId, scenario.firstRole)

			// creating another assignment shouldn't add another entry, as we support max one role per user.
			// assigning the second role should remove the old
			secondAssignment, err := s.WriteRoleAssignment(scenario.userID, scenario.secondRole)
			require.NoError(t, err)
			require.Equal(t, secondAssignment.RoleId, scenario.secondRole)

			list, err = s.ListRoleAssignments(scenario.userID)
			require.NoError(t, err)
			require.Equal(t, 1, len(list))
			require.Equal(t, list[0].RoleId, scenario.secondRole)
		})
	}
}

func TestDeleteAssignment(t *testing.T) {
	var scenarios = []struct {
		name       string
		userID     string
		firstRole  string
		secondRole string
	}{
		{
			"roles assignments",
			einstein,
			"f36db5e6-a03c-40df-8413-711c67e40b47",
			"44f1a664-0a7f-461a-b0be-5b59e46bbc7a",
		},
	}

	for _, scenario := range scenarios {
		scenario := scenario
		t.Run(scenario.name, func(t *testing.T) {
			assignment, err := s.WriteRoleAssignment(scenario.userID, scenario.firstRole)
			require.NoError(t, err)
			require.Equal(t, assignment.RoleId, scenario.firstRole)
			// TODO: uncomment
			// require.True(t, mdc.IDExists(assignment.RoleId))

			list, err := s.ListRoleAssignments(scenario.userID)
			require.NoError(t, err)
			require.Equal(t, 1, len(list))
			require.Equal(t, assignment.Id, list[0].Id)

			err = s.RemoveRoleAssignment(assignment.Id)
			require.NoError(t, err)
			// TODO: uncomment
			// require.False(t, mdc.IDExists(assignment.RoleId))

			list, err = s.ListRoleAssignments(scenario.userID)
			require.NoError(t, err)
			require.Equal(t, 0, len(list))

			err = s.RemoveRoleAssignment(assignment.Id)
			require.Error(t, err)
			// TODO: do we want a custom error message?
		})
	}
}
