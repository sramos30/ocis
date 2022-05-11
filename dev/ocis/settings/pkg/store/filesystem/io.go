package store

import (
	"io/ioutil"
	"os"

	"github.com/owncloud/ocis/settings/pkg/store/errortypes"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

// Unmarshal file into record
func (s Store) parseRecordFromFile(record proto.Message, filePath string) error {
	_, err := os.Stat(filePath)
	if err != nil {
		return errortypes.BundleNotFound(err.Error())
	}

	file, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	b, err := ioutil.ReadAll(file)
	if err != nil {
		return err
	}

	if len(b) == 0 {
		return errortypes.BundleNotFound(filePath)
	}

	if err := protojson.Unmarshal(b, record); err != nil {
		return err
	}
	return nil
}

// Marshal record into file
func (s Store) writeRecordToFile(record proto.Message, filePath string) error {
	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	v, err := protojson.Marshal(record)
	if err != nil {
		return err
	}

	_, err = file.Write(v)
	if err != nil {
		return err
	}

	return nil
}
