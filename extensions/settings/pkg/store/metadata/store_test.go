package store

import (
	"context"
	"strings"

	"github.com/owncloud/ocis/v2/extensions/settings/pkg/config/defaults"
)

const (
	// account UUIDs
	accountUUID1 = "c4572da7-6142-4383-8fc6-efde3d463036"
	//accountUUID2 = "e11f9769-416a-427d-9441-41a0e51391d7"
	//accountUUID3 = "633ecd77-1980-412a-8721-bf598a330bb4"

	// extension names
	extension1 = "test-extension-1"
	extension2 = "test-extension-2"

	// bundle ids
	bundle1 = "2f06addf-4fd2-49d5-8f71-00fbd3a3ec47"
	bundle2 = "2d745744-749c-4286-8e92-74a24d8331c5"
	bundle3 = "d8fd27d1-c00b-4794-a658-416b756a72ff"

	// setting ids
	setting1 = "c7ebbc8b-d15a-4f2e-9d7d-d6a4cf858d1a"
	setting2 = "3fd9a3d9-20b7-40d4-9294-b22bb5868c10"
	setting3 = "24bb9535-3df4-42f1-a622-7c0562bec99f"

	// value ids
	value1 = "fd3b6221-dc13-4a22-824d-2480495f1cdb"
	value2 = "2a0bd9b0-ca1d-491a-8c56-d2ddfd68ded8"
	value3 = "b42702d2-5e4d-4d73-b133-e1f9e285355e"
)

// use "unit" or "integration" do define test type. You need a running ocis instance for integration tests
var testtype = "unit"

// MockedMetadataClient mocks the metadataservice inmemory
type MockedMetadataClient struct {
	data map[string][]byte
}

// NewMDC instantiates a mocked MetadataClient
func NewMDC(s *Store) error {
	var mdc MetadataClient
	switch testtype {
	case "unit":
		mdc = &MockedMetadataClient{data: make(map[string][]byte)}
	case "integration":
		mdc = NewMetadataClient(defaults.DefaultConfig().Metadata)
	}
	return s.initMetadataClient(mdc)
}

// SimpleDownload returns nil if not found
func (m *MockedMetadataClient) SimpleDownload(_ context.Context, id string) ([]byte, error) {
	return m.data[id], nil
}

// SimpleUpload can't error
func (m *MockedMetadataClient) SimpleUpload(_ context.Context, id string, content []byte) error {
	m.data[id] = content
	return nil
}

// Delete can't error either
func (m *MockedMetadataClient) Delete(_ context.Context, id string) error {
	for k := range m.data {
		if strings.HasPrefix(k, id) {
			delete(m.data, k)
		}
	}
	return nil
}

// ReadDir returns nil, nil if not found
func (m *MockedMetadataClient) ReadDir(_ context.Context, id string) ([]string, error) {
	var out []string
	for k := range m.data {
		if strings.HasPrefix(k, id) {
			dir := strings.TrimPrefix(k, id+"/")
			// filter subfolders the lame way
			s := strings.Trim(strings.SplitAfter(dir, "/")[0], "/")
			out = append(out, s)
		}
	}
	return out, nil
}

// MakeDirIfNotExist does nothing
func (*MockedMetadataClient) MakeDirIfNotExist(_ context.Context, _ string) error {
	return nil
}

// Init does nothing
func (*MockedMetadataClient) Init(_ context.Context, _ string) error {
	return nil
}

// IDExists is a helper to check if an id exists
func (m *MockedMetadataClient) IDExists(id string) bool {
	_, ok := m.data[id]
	return ok
}

// IDHasContent returns true if the value stored under id has the given content (converted to string)
func (m *MockedMetadataClient) IDHasContent(id string, content []byte) bool {
	return string(m.data[id]) == string(content)
}
