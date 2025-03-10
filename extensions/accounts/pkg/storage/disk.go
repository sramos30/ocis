package storage

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"os"
	"path/filepath"
	"sync"

	accountsmsg "github.com/owncloud/ocis/v2/protogen/gen/ocis/messages/accounts/v0"

	"github.com/owncloud/ocis/v2/extensions/accounts/pkg/config"
	olog "github.com/owncloud/ocis/v2/ocis-pkg/log"
)

var groupLock sync.Mutex

// DiskRepo provides a local filesystem implementation of the Repo interface
type DiskRepo struct {
	cfg *config.Config
	log olog.Logger
}

// NewDiskRepo creates a new disk repo
func NewDiskRepo(cfg *config.Config, log olog.Logger) DiskRepo {
	paths := []string{
		filepath.Join(cfg.Repo.Disk.Path, accountsFolder),
		filepath.Join(cfg.Repo.Disk.Path, groupsFolder),
	}
	for i := range paths {
		if _, err := os.Stat(paths[i]); err != nil {
			if os.IsNotExist(err) {
				if err = os.MkdirAll(paths[i], 0700); err != nil {
					log.Fatal().Err(err).Msgf("could not create data folder %v", paths[i])
				}
			}
		}
	}
	return DiskRepo{
		cfg: cfg,
		log: log,
	}
}

// WriteAccount to the local filesystem
func (r DiskRepo) WriteAccount(ctx context.Context, a *accountsmsg.Account) (err error) {
	// leave only the group id
	r.deflateMemberOf(a)

	var bytes []byte
	if bytes, err = json.Marshal(a); err != nil {
		return err
	}

	path := filepath.Join(r.cfg.Repo.Disk.Path, accountsFolder, a.Id)
	return ioutil.WriteFile(path, bytes, 0600)
}

// LoadAccount from the local filesystem
func (r DiskRepo) LoadAccount(ctx context.Context, id string, a *accountsmsg.Account) (err error) {
	path := filepath.Join(r.cfg.Repo.Disk.Path, accountsFolder, id)
	var data []byte
	if data, err = ioutil.ReadFile(path); err != nil {
		if os.IsNotExist(err) {
			err = &notFoundErr{"account", id}
		}
		return
	}

	return json.Unmarshal(data, a)
}

// LoadAccounts loads all the accounts from the local filesystem
func (r DiskRepo) LoadAccounts(ctx context.Context, a *[]*accountsmsg.Account) (err error) {
	root := filepath.Join(r.cfg.Repo.Disk.Path, accountsFolder)
	infos, err := ioutil.ReadDir(root)
	if err != nil {
		return err
	}
	for i := range infos {
		acc := &accountsmsg.Account{}
		if e := r.LoadAccount(ctx, infos[i].Name(), acc); e != nil {
			r.log.Err(e).Msg("could not load account")
			continue
		}
		*a = append(*a, acc)
	}
	return nil
}

// DeleteAccount from the local filesystem
func (r DiskRepo) DeleteAccount(ctx context.Context, id string) (err error) {
	path := filepath.Join(r.cfg.Repo.Disk.Path, accountsFolder, id)
	if err = os.Remove(path); err != nil {
		if os.IsNotExist(err) {
			err = &notFoundErr{"account", id}
		}
	}

	return
}

// WriteGroup to the local filesystem
func (r DiskRepo) WriteGroup(ctx context.Context, g *accountsmsg.Group) (err error) {
	// leave only the member id
	r.deflateMembers(g)

	var bytes []byte
	if bytes, err = json.Marshal(g); err != nil {
		return err
	}

	path := filepath.Join(r.cfg.Repo.Disk.Path, groupsFolder, g.Id)

	groupLock.Lock()
	defer groupLock.Unlock()

	return ioutil.WriteFile(path, bytes, 0600)
}

// LoadGroup from the local filesystem
func (r DiskRepo) LoadGroup(ctx context.Context, id string, g *accountsmsg.Group) (err error) {
	path := filepath.Join(r.cfg.Repo.Disk.Path, groupsFolder, id)

	groupLock.Lock()
	defer groupLock.Unlock()
	var data []byte
	if data, err = ioutil.ReadFile(path); err != nil {
		if os.IsNotExist(err) {
			err = &notFoundErr{"group", id}
		}

		return
	}

	return json.Unmarshal(data, g)
}

// LoadGroups loads all the groups from the local filesystem
func (r DiskRepo) LoadGroups(ctx context.Context, g *[]*accountsmsg.Group) (err error) {
	root := filepath.Join(r.cfg.Repo.Disk.Path, groupsFolder)
	infos, err := ioutil.ReadDir(root)
	if err != nil {
		return err
	}
	for i := range infos {
		grp := &accountsmsg.Group{}
		if e := r.LoadGroup(ctx, infos[i].Name(), grp); e != nil {
			r.log.Err(e).Msg("could not load group")
			continue
		}
		*g = append(*g, grp)
	}
	return nil
}

// DeleteGroup from the local filesystem
func (r DiskRepo) DeleteGroup(ctx context.Context, id string) (err error) {
	path := filepath.Join(r.cfg.Repo.Disk.Path, groupsFolder, id)
	if err = os.Remove(path); err != nil {
		if os.IsNotExist(err) {
			err = &notFoundErr{"account", id}
		}
	}

	return
}

// deflateMemberOf replaces the groups of a user with an instance that only contains the id
func (r DiskRepo) deflateMemberOf(a *accountsmsg.Account) {
	if a == nil {
		return
	}
	var deflated []*accountsmsg.Group
	for i := range a.MemberOf {
		if a.MemberOf[i].Id != "" {
			deflated = append(deflated, &accountsmsg.Group{Id: a.MemberOf[i].Id})
		} else {
			// TODO fetch and use an id when group only has a name but no id
			r.log.Error().Str("id", a.Id).Interface("group", a.MemberOf[i]).Msg("resolving groups by name is not implemented yet")
		}
	}
	a.MemberOf = deflated
}

// deflateMembers replaces the users of a group with an instance that only contains the id
func (r DiskRepo) deflateMembers(g *accountsmsg.Group) {
	if g == nil {
		return
	}
	var deflated []*accountsmsg.Account
	for i := range g.Members {
		if g.Members[i].Id != "" {
			deflated = append(deflated, &accountsmsg.Account{Id: g.Members[i].Id})
		} else {
			// TODO fetch and use an id when group only has a name but no id
			r.log.Error().Str("id", g.Id).Interface("account", g.Members[i]).Msg("resolving members by name is not implemented yet")
		}
	}
	g.Members = deflated
}
