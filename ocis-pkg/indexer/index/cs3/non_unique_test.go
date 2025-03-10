package cs3

//
//import (
//	"os"
//	"path"
//	"testing"
//
//	"github.com/owncloud/ocis/v2/accounts/pkg/config"
//	"github.com/owncloud/ocis/v2/ocis-pkg/indexer/option"
//	. "github.com/owncloud/ocis/v2/ocis-pkg/indexer/test"
//	"github.com/stretchr/testify/assert"
//)
//
//func TestCS3NonUniqueIndex_FakeSymlink(t *testing.T) {
//	dataDir, err := WriteIndexTestData(Data, "ID", cs3RootFolder)
//	assert.NoError(t, err)
//	cfg := config.Config{
//		Repo: config.Repo{
//			Disk: config.Disk{
//				Path: "",
//			},
//			CS3: config.CS3{
//				ProviderAddr: "0.0.0.0:9215",
//				DataURL:      "http://localhost:9216",
//				DataPrefix:   "data",
//				JWTSecret:    "Pive-Fumkiu4",
//			},
//		},
//	}
//
//	sut := NewNonUniqueIndexWithOptions(
//		option.WithTypeName(GetTypeFQN(User{})),
//		option.WithIndexBy("UserName"),
//		option.WithFilesDir(path.Join(cfg.Repo.Disk.Path, "/")),
//		option.WithDataDir(cfg.Repo.Disk.Path),
//		option.WithDataURL(cfg.Repo.CS3.DataURL),
//		option.WithDataPrefix(cfg.Repo.CS3.DataPrefix),
//		option.WithJWTSecret(cfg.Repo.CS3.JWTSecret),
//		option.WithProviderAddr(cfg.Repo.CS3.ProviderAddr),
//	)
//
//	err = sut.Init()
//	assert.NoError(t, err)
//
//	res, err := sut.Add("abcdefg-123", "mikey")
//	assert.NoError(t, err)
//	t.Log(res)
//
//	resLookup, err := sut.Lookup("mikey")
//	assert.NoError(t, err)
//	t.Log(resLookup)
//
//	err = sut.Update("abcdefg-123", "mikey", "mickeyX")
//	assert.NoError(t, err)
//
//	searchRes, err := sut.Search("m*")
//	assert.NoError(t, err)
//	assert.Len(t, searchRes, 1)
//	assert.Equal(t, searchRes[0], "abcdefg-123")
//
//	resp, err := sut.Lookup("mikey")
//	assert.Len(t, resp, 0)
//	assert.NoError(t, err)
//
//	_ = os.RemoveAll(dataDir)
//
//}
