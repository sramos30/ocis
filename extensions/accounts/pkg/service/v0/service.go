package service

import (
	"context"
	"path"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	accountsmsg "github.com/owncloud/ocis/v2/protogen/gen/ocis/messages/accounts/v0"
	"github.com/pkg/errors"

	"github.com/owncloud/ocis/v2/ocis-pkg/service/grpc"

	"github.com/owncloud/ocis/v2/extensions/accounts/pkg/storage"
	"github.com/owncloud/ocis/v2/ocis-pkg/indexer"
	idxcfg "github.com/owncloud/ocis/v2/ocis-pkg/indexer/config"
	idxerrs "github.com/owncloud/ocis/v2/ocis-pkg/indexer/errors"

	"github.com/owncloud/ocis/v2/extensions/accounts/pkg/config"
	"github.com/owncloud/ocis/v2/ocis-pkg/log"
	oreg "github.com/owncloud/ocis/v2/ocis-pkg/registry"
	"github.com/owncloud/ocis/v2/ocis-pkg/roles"
	settingssvc "github.com/owncloud/ocis/v2/protogen/gen/ocis/services/settings/v0"
)

// userDefaultGID is the default integer representing the "users" group.
const userDefaultGID = 30000

// New returns a new instance of Service
func New(opts ...Option) (s *Service, err error) {
	options := newOptions(opts...)
	logger := options.Logger
	cfg := options.Config

	roleService := options.RoleService
	if roleService == nil {
		roleService = settingssvc.NewRoleService("com.owncloud.api.settings", grpc.DefaultClient)
	}
	roleManager := options.RoleManager
	if roleManager == nil {
		m := roles.NewManager(
			roles.CacheSize(1024),
			roles.CacheTTL(time.Hour*24*7),
			roles.Logger(options.Logger),
			roles.RoleService(roleService),
		)
		roleManager = &m
	}

	storage, err := createMetadataStorage(cfg, logger)
	if err != nil {
		return nil, errors.Wrap(err, "could not create metadata storage")
	}

	s = &Service{
		id:          cfg.GRPC.Namespace + "." + cfg.Service.Name,
		log:         logger,
		Config:      cfg,
		RoleService: roleService,
		RoleManager: roleManager,
		repo:        storage,
	}

	r := oreg.GetRegistry()
	if cfg.Repo.Backend == "cs3" {
		if _, err := r.GetService("com.owncloud.storage.metadata"); err != nil {
			logger.Error().Err(err).Msg("index: storage-system service not present")
			return nil, err
		}
	}

	// we want to wait anyway. If it depends on a reva service it could be the case that the entry on the registry
	// happens prior to the reva service being up and running
	time.Sleep(500 * time.Millisecond)

	if s.index, err = s.buildIndex(); err != nil {
		return nil, err
	}

	if err = s.createDefaultAccounts(cfg.DemoUsersAndGroups); err != nil {
		return nil, err
	}

	if err = s.createDefaultGroups(cfg.DemoUsersAndGroups); err != nil {
		return nil, err
	}

	s.serviceUserToIndex()
	return
}

// serviceUserToIndex temporarily adds a service user to the index, which is supposed to be removed before the lock on the handler function is released
func (s Service) serviceUserToIndex() {
	if s.Config.ServiceUser.Username != "" && s.Config.ServiceUser.UUID != "" {
		_, err := s.index.Add(s.getInMemoryServiceUser())
		if err != nil {
			s.log.Logger.Err(err).Msg("service user was configured but failed to be added to the index")
		}
	}
}

func (s Service) getInMemoryServiceUser() accountsmsg.Account {
	return accountsmsg.Account{
		AccountEnabled:           true,
		Id:                       s.Config.ServiceUser.UUID,
		PreferredName:            s.Config.ServiceUser.Username,
		OnPremisesSamAccountName: s.Config.ServiceUser.Username,
		DisplayName:              s.Config.ServiceUser.Username,
		UidNumber:                s.Config.ServiceUser.UID,
		GidNumber:                s.Config.ServiceUser.GID,
	}
}

func (s Service) buildIndex() (*indexer.Indexer, error) {
	var indexcfg *idxcfg.Config

	indexcfg, err := configFromSvc(s.Config)
	if err != nil {
		return nil, err
	}
	idx := indexer.CreateIndexer(indexcfg)

	if err := recreateContainers(idx, indexcfg); err != nil {
		return nil, err
	}
	return idx, nil
}

// configFromSvc creates an index config out of a service configuration. This intermediate step exists
// because the index config was mapped after the service config.
func configFromSvc(cfg *config.Config) (*idxcfg.Config, error) {
	c := idxcfg.New()

	if cfg.Log == nil {
		cfg.Log = &config.Log{}
	}

	defer func(cfg *config.Config) {
		l := log.NewLogger(log.Color(cfg.Log.Color), log.Pretty(cfg.Log.Pretty), log.Level(cfg.Log.Level))
		if r := recover(); r != nil {
			l.Error().
				Str("panic", "recovered from panic while parsing index config from service configuration").
				Interface("svc_config", cfg).
				Msg("recovered from panic")
		}
	}(cfg)

	switch cfg.Repo.Backend {
	case "disk":
		c.Repo = idxcfg.Repo{
			Backend: cfg.Repo.Backend,
			Disk: idxcfg.Disk{
				Path: cfg.Repo.Disk.Path,
			},
		}
	case "cs3":
		c.Repo = idxcfg.Repo{
			Backend: cfg.Repo.Backend,
			CS3: idxcfg.CS3{
				ProviderAddr: cfg.Repo.CS3.ProviderAddr,
				JWTSecret:    cfg.TokenManager.JWTSecret,
			},
		}
	default:
		return nil, errors.New("index backend " + cfg.Repo.Backend + " is not supported")
	}

	if (config.Index{}) != cfg.Index {
		c.Index = idxcfg.Index{
			UID: idxcfg.Bound{
				Lower: cfg.Index.UID.Lower,
			},
			GID: idxcfg.Bound{
				Lower: cfg.Index.GID.Lower,
			},
		}
	}

	if (config.ServiceUser{}) != cfg.ServiceUser {
		c.ServiceUser = cfg.ServiceUser
	}

	return c, nil
}

func (s Service) createDefaultAccounts(withDemoAccounts bool) (err error) {
	accounts := []accountsmsg.Account{
		{
			Id:                       "4c510ada-c86b-4815-8820-42cdf82c3d51",
			PreferredName:            "einstein",
			OnPremisesSamAccountName: "einstein",
			Mail:                     "einstein@example.org",
			DisplayName:              "Albert Einstein",
			UidNumber:                20000,
			GidNumber:                30000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$L.Rkpa0/nOhF3SsFo.QY9uzjMG8zB9a8dZP./LZBCDgsiuI8w10Em",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa"}, // users
				{Id: "6040aa17-9c64-4fef-9bd0-77234d71bad0"}, // sailing-lovers
				{Id: "dd58e5ec-842e-498b-8800-61f2ec6f911f"}, // violin-haters
				{Id: "262982c1-2362-4afa-bfdf-8cbfef64a06e"}, // physics-lovers
			},
		},
		{
			Id:                       "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c",
			PreferredName:            "marie",
			OnPremisesSamAccountName: "marie",
			Mail:                     "marie@example.org",
			DisplayName:              "Marie Curie",
			UidNumber:                20001,
			GidNumber:                30000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$AZd1k6OVpzP7E4hw5.ysFuuL2.XjjgakAuRs2zdBvIMizF0KaZkNG",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa"}, // users
				{Id: "7b87fd49-286e-4a5f-bafd-c535d5dd997a"}, // radium-lovers
				{Id: "cedc21aa-4072-4614-8676-fa9165f598ff"}, // polonium-lovers
				{Id: "262982c1-2362-4afa-bfdf-8cbfef64a06e"}, // physics-lovers
			},
		},
		{
			Id:                       "932b4540-8d16-481e-8ef4-588e4b6b151c",
			PreferredName:            "richard",
			OnPremisesSamAccountName: "richard",
			Mail:                     "richard@example.org",
			DisplayName:              "Richard Feynman",
			UidNumber:                20002,
			GidNumber:                30000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$aeVYaBH3LCTj9DviV6Y4xO2reoEzY9vnc7a5/0mhJWQUDtPqPINme",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa"}, // users
				{Id: "a1726108-01f8-4c30-88df-2b1a9d1cba1a"}, // quantum-lovers
				{Id: "167cbee2-0518-455a-bfb2-031fe0621e5d"}, // philosophy-haters
				{Id: "262982c1-2362-4afa-bfdf-8cbfef64a06e"}, // physics-lovers
			},
		},
		// admin user(s)
		{
			Id:                       "058bff95-6708-4fe5-91e4-9ea3d377588b",
			PreferredName:            "moss",
			OnPremisesSamAccountName: "moss",
			Mail:                     "moss@example.org",
			DisplayName:              "Maurice Moss",
			UidNumber:                20003,
			GidNumber:                30000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$la2yFV6N.pPySwHnLIxyAuBCJ2t/DxWfXJGnIooA9Ebb3.lSTKXby",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa"}, // users
			},
		},
		{
			Id:                       "ddc2004c-0977-11eb-9d3f-a793888cd0f8",
			PreferredName:            "admin",
			OnPremisesSamAccountName: "admin",
			Mail:                     "admin@example.org",
			DisplayName:              "Admin",
			UidNumber:                20004,
			GidNumber:                30000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$zqpfwdtBUDg89cpltxd.9ef7ZMzsor1BLCJyTEcdoitmEuS3Hr/Q6",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa"}, // users
			},
		},
		{
			Id:                       "534bb038-6f9d-4093-946f-133be61fa4e7",
			PreferredName:            "katherine",
			OnPremisesSamAccountName: "katherine",
			Mail:                     "katherine@example.org",
			DisplayName:              "Katherine Johnson",
			UidNumber:                20005,
			GidNumber:                30000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$j0//gOyZ3xg/WtMOk4XUaOMJ1r5niD3paPcFh1O/PNr8pL7yC8rhG",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa"}, // users
				{Id: "6040aa17-9c64-4fef-9bd0-77234d71bad0"}, // sailing-lovers
				{Id: "a1726108-01f8-4c30-88df-2b1a9d1cba1a"}, // quantum-lovers
				{Id: "262982c1-2362-4afa-bfdf-8cbfef64a06e"}, // physics-lovers
			},
		},
		// technical users for kopano and reva
		{
			Id:                       "820ba2a1-3f54-4538-80a4-2d73007e30bf",
			PreferredName:            "idp",
			OnPremisesSamAccountName: "idp",
			Mail:                     "idp@example.org",
			DisplayName:              "Kopano IDP",
			UidNumber:                10000,
			GidNumber:                15000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$TiuPj61Lkwt9hPOj4UUdwO.fupKBO3gpMv1EoXo0XF8Z8L9rFN8Nm",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "34f38767-c937-4eb6-b847-1c175829a2a0"}, // sysusers
			},
		},
		{
			Id:                       "bc596f3c-c955-4328-80a0-60d018b4ad57",
			PreferredName:            "reva",
			OnPremisesSamAccountName: "reva",
			Mail:                     "storage@example.org",
			DisplayName:              "Reva Inter Operability Platform",
			UidNumber:                10001,
			GidNumber:                15000,
			PasswordProfile: &accountsmsg.PasswordProfile{
				Password: "$2a$04$.cYhDMMXsvoCJzH9rX0eKev7fsLZwUv.VsRn66iaCXj2KlgpzHu3a",
			},
			AccountEnabled: true,
			MemberOf: []*accountsmsg.Group{
				{Id: "34f38767-c937-4eb6-b847-1c175829a2a0"}, // sysusers
			},
		},
	}

	mustHaveAccounts := map[string]bool{
		"bc596f3c-c955-4328-80a0-60d018b4ad57": true, // Reva IOP
		"820ba2a1-3f54-4538-80a4-2d73007e30bf": true, // Kopano IDP
		"ddc2004c-0977-11eb-9d3f-a793888cd0f8": true, // admin
	}

	// this only deals with the metadata service.
	for i := range accounts {
		if !withDemoAccounts && !mustHaveAccounts[accounts[i].Id] {
			continue
		}

		a := &accountsmsg.Account{}
		err := s.repo.LoadAccount(context.Background(), accounts[i].Id, a)
		if !storage.IsNotFoundErr(err) {
			continue // account already exists -> do not overwrite
		}

		if err := s.repo.WriteAccount(context.Background(), &accounts[i]); err != nil {
			return err
		}

		results, err := s.index.Add(&accounts[i])
		if err != nil {
			if idxerrs.IsAlreadyExistsErr(err) {
				continue
			} else {
				return err
			}
		}

		changed := false
		for _, r := range results {
			if r.Field == "UidNumber" || r.Field == "GidNumber" {
				id, err := strconv.ParseInt(path.Base(r.Value), 10, 0)
				if err != nil {
					return err
				}
				if r.Field == "UidNumber" {
					accounts[i].UidNumber = id
				} else {
					accounts[i].GidNumber = id
				}
				changed = true
			}
		}
		if changed {
			if err := s.repo.WriteAccount(context.Background(), &accounts[i]); err != nil {
				return err
			}
		}
	}
	return nil
}

func (s Service) createDefaultGroups(withDemoGroups bool) (err error) {
	groups := []accountsmsg.Group{
		{Id: "34f38767-c937-4eb6-b847-1c175829a2a0", GidNumber: 15000, OnPremisesSamAccountName: "sysusers", DisplayName: "Technical users", Description: "A group for technical users. They should not show up in sharing dialogs.", Members: []*accountsmsg.Account{
			{Id: "820ba2a1-3f54-4538-80a4-2d73007e30bf"}, // idp
			{Id: "bc596f3c-c955-4328-80a0-60d018b4ad57"}, // reva
		}},
		{Id: "509a9dcd-bb37-4f4f-a01a-19dca27d9cfa", GidNumber: 30000, OnPremisesSamAccountName: "users", DisplayName: "Users", Description: "A group every normal user belongs to.", Members: []*accountsmsg.Account{
			{Id: "4c510ada-c86b-4815-8820-42cdf82c3d51"}, // einstein
			{Id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c"}, // marie
			{Id: "932b4540-8d16-481e-8ef4-588e4b6b151c"}, // feynman
			{Id: "534bb038-6f9d-4093-946f-133be61fa4e7"}, // katherine
		}},
		{Id: "6040aa17-9c64-4fef-9bd0-77234d71bad0", GidNumber: 30001, OnPremisesSamAccountName: "sailing-lovers", DisplayName: "Sailing lovers", Members: []*accountsmsg.Account{
			{Id: "4c510ada-c86b-4815-8820-42cdf82c3d51"}, // einstein
			{Id: "534bb038-6f9d-4093-946f-133be61fa4e7"}, // katherine
		}},
		{Id: "dd58e5ec-842e-498b-8800-61f2ec6f911f", GidNumber: 30002, OnPremisesSamAccountName: "violin-haters", DisplayName: "Violin haters", Members: []*accountsmsg.Account{
			{Id: "4c510ada-c86b-4815-8820-42cdf82c3d51"}, // einstein
		}},
		{Id: "7b87fd49-286e-4a5f-bafd-c535d5dd997a", GidNumber: 30003, OnPremisesSamAccountName: "radium-lovers", DisplayName: "Radium lovers", Members: []*accountsmsg.Account{
			{Id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c"}, // marie
		}},
		{Id: "cedc21aa-4072-4614-8676-fa9165f598ff", GidNumber: 30004, OnPremisesSamAccountName: "polonium-lovers", DisplayName: "Polonium lovers", Members: []*accountsmsg.Account{
			{Id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c"}, // marie
		}},
		{Id: "a1726108-01f8-4c30-88df-2b1a9d1cba1a", GidNumber: 30005, OnPremisesSamAccountName: "quantum-lovers", DisplayName: "Quantum lovers", Members: []*accountsmsg.Account{
			{Id: "932b4540-8d16-481e-8ef4-588e4b6b151c"}, // feynman
			{Id: "534bb038-6f9d-4093-946f-133be61fa4e7"}, // katherine
		}},
		{Id: "167cbee2-0518-455a-bfb2-031fe0621e5d", GidNumber: 30006, OnPremisesSamAccountName: "philosophy-haters", DisplayName: "Philosophy haters", Members: []*accountsmsg.Account{
			{Id: "932b4540-8d16-481e-8ef4-588e4b6b151c"}, // feynman
		}},
		{Id: "262982c1-2362-4afa-bfdf-8cbfef64a06e", GidNumber: 30007, OnPremisesSamAccountName: "physics-lovers", DisplayName: "Physics lovers", Members: []*accountsmsg.Account{
			{Id: "4c510ada-c86b-4815-8820-42cdf82c3d51"}, // einstein
			{Id: "f7fbf8c8-139b-4376-b307-cf0a8c2d0d9c"}, // marie
			{Id: "932b4540-8d16-481e-8ef4-588e4b6b151c"}, // feynman
			{Id: "534bb038-6f9d-4093-946f-133be61fa4e7"}, // katherine
		}},
	}

	mustHaveGroups := map[string]bool{
		"34f38767-c937-4eb6-b847-1c175829a2a0": true, // sysusers
		"509a9dcd-bb37-4f4f-a01a-19dca27d9cfa": true, // users
	}

	for i := range groups {
		if !withDemoGroups && !mustHaveGroups[groups[i].Id] {
			continue
		}

		g := &accountsmsg.Group{}
		err := s.repo.LoadGroup(context.Background(), groups[i].Id, g)
		if !storage.IsNotFoundErr(err) {
			continue // group already exists -> do not overwrite
		}

		if err := s.repo.WriteGroup(context.Background(), &groups[i]); err != nil {
			return err
		}

		results, err := s.index.Add(&groups[i])
		if err != nil {
			if idxerrs.IsAlreadyExistsErr(err) {
				continue
			} else {
				return err
			}
		}

		// TODO: can be removed again as soon as we respect the predefined GIDs from the group. Then no autoincrement is happening, therefore we don't need to update groups.
		for _, r := range results {
			if r.Field == "GidNumber" {
				gid, err := strconv.ParseInt(path.Base(r.Value), 10, 0)
				if err != nil {
					return err
				}
				groups[i].GidNumber = gid
				if err := s.repo.WriteGroup(context.Background(), &groups[i]); err != nil {
					return err
				}
				break
			}
		}
	}
	return nil
}

func createMetadataStorage(cfg *config.Config, logger log.Logger) (storage.Repo, error) {
	switch cfg.Repo.Backend {
	case "disk":
		return storage.NewDiskRepo(cfg, logger), nil
	case "cs3":
		repo, err := storage.NewCS3Repo(cfg)
		if err != nil {
			return nil, errors.Wrap(err, "cs3 backend was configured but failed to start")
		}
		return repo, nil
	default:
		return nil, errors.New("backend type " + cfg.Repo.Backend + " is not supported")
	}
}

// Service implements the AccountsServiceHandler interface
type Service struct {
	id          string
	log         log.Logger
	Config      *config.Config
	index       *indexer.Indexer
	RoleService settingssvc.RoleService
	RoleManager *roles.Manager
	repo        storage.Repo
}

func cleanupID(id string) (string, error) {
	id = filepath.Clean(id)
	if id == "." || strings.Contains(id, "/") {
		return "", errors.New("invalid id " + id)
	}
	return id, nil
}
