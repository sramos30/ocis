// Code generated by mockery v2.10.0. DO NOT EDIT.

package mocks

import (
	context "context"

	bleve "github.com/blevesearch/bleve/v2"

	index "github.com/blevesearch/bleve_index_api"

	mapping "github.com/blevesearch/bleve/v2/mapping"

	mock "github.com/stretchr/testify/mock"
)

// BleveIndex is an autogenerated mock type for the BleveIndex type
type BleveIndex struct {
	mock.Mock
}

// Advanced provides a mock function with given fields:
func (_m *BleveIndex) Advanced() (index.Index, error) {
	ret := _m.Called()

	var r0 index.Index
	if rf, ok := ret.Get(0).(func() index.Index); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(index.Index)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func() error); ok {
		r1 = rf()
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Batch provides a mock function with given fields: b
func (_m *BleveIndex) Batch(b *bleve.Batch) error {
	ret := _m.Called(b)

	var r0 error
	if rf, ok := ret.Get(0).(func(*bleve.Batch) error); ok {
		r0 = rf(b)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// Close provides a mock function with given fields:
func (_m *BleveIndex) Close() error {
	ret := _m.Called()

	var r0 error
	if rf, ok := ret.Get(0).(func() error); ok {
		r0 = rf()
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// Delete provides a mock function with given fields: id
func (_m *BleveIndex) Delete(id string) error {
	ret := _m.Called(id)

	var r0 error
	if rf, ok := ret.Get(0).(func(string) error); ok {
		r0 = rf(id)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// DeleteInternal provides a mock function with given fields: key
func (_m *BleveIndex) DeleteInternal(key []byte) error {
	ret := _m.Called(key)

	var r0 error
	if rf, ok := ret.Get(0).(func([]byte) error); ok {
		r0 = rf(key)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// DocCount provides a mock function with given fields:
func (_m *BleveIndex) DocCount() (uint64, error) {
	ret := _m.Called()

	var r0 uint64
	if rf, ok := ret.Get(0).(func() uint64); ok {
		r0 = rf()
	} else {
		r0 = ret.Get(0).(uint64)
	}

	var r1 error
	if rf, ok := ret.Get(1).(func() error); ok {
		r1 = rf()
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Document provides a mock function with given fields: id
func (_m *BleveIndex) Document(id string) (index.Document, error) {
	ret := _m.Called(id)

	var r0 index.Document
	if rf, ok := ret.Get(0).(func(string) index.Document); ok {
		r0 = rf(id)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(index.Document)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(string) error); ok {
		r1 = rf(id)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// FieldDict provides a mock function with given fields: field
func (_m *BleveIndex) FieldDict(field string) (index.FieldDict, error) {
	ret := _m.Called(field)

	var r0 index.FieldDict
	if rf, ok := ret.Get(0).(func(string) index.FieldDict); ok {
		r0 = rf(field)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(index.FieldDict)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(string) error); ok {
		r1 = rf(field)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// FieldDictPrefix provides a mock function with given fields: field, termPrefix
func (_m *BleveIndex) FieldDictPrefix(field string, termPrefix []byte) (index.FieldDict, error) {
	ret := _m.Called(field, termPrefix)

	var r0 index.FieldDict
	if rf, ok := ret.Get(0).(func(string, []byte) index.FieldDict); ok {
		r0 = rf(field, termPrefix)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(index.FieldDict)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(string, []byte) error); ok {
		r1 = rf(field, termPrefix)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// FieldDictRange provides a mock function with given fields: field, startTerm, endTerm
func (_m *BleveIndex) FieldDictRange(field string, startTerm []byte, endTerm []byte) (index.FieldDict, error) {
	ret := _m.Called(field, startTerm, endTerm)

	var r0 index.FieldDict
	if rf, ok := ret.Get(0).(func(string, []byte, []byte) index.FieldDict); ok {
		r0 = rf(field, startTerm, endTerm)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(index.FieldDict)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(string, []byte, []byte) error); ok {
		r1 = rf(field, startTerm, endTerm)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Fields provides a mock function with given fields:
func (_m *BleveIndex) Fields() ([]string, error) {
	ret := _m.Called()

	var r0 []string
	if rf, ok := ret.Get(0).(func() []string); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).([]string)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func() error); ok {
		r1 = rf()
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// GetInternal provides a mock function with given fields: key
func (_m *BleveIndex) GetInternal(key []byte) ([]byte, error) {
	ret := _m.Called(key)

	var r0 []byte
	if rf, ok := ret.Get(0).(func([]byte) []byte); ok {
		r0 = rf(key)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).([]byte)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func([]byte) error); ok {
		r1 = rf(key)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Index provides a mock function with given fields: id, data
func (_m *BleveIndex) Index(id string, data interface{}) error {
	ret := _m.Called(id, data)

	var r0 error
	if rf, ok := ret.Get(0).(func(string, interface{}) error); ok {
		r0 = rf(id, data)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// Mapping provides a mock function with given fields:
func (_m *BleveIndex) Mapping() mapping.IndexMapping {
	ret := _m.Called()

	var r0 mapping.IndexMapping
	if rf, ok := ret.Get(0).(func() mapping.IndexMapping); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(mapping.IndexMapping)
		}
	}

	return r0
}

// Name provides a mock function with given fields:
func (_m *BleveIndex) Name() string {
	ret := _m.Called()

	var r0 string
	if rf, ok := ret.Get(0).(func() string); ok {
		r0 = rf()
	} else {
		r0 = ret.Get(0).(string)
	}

	return r0
}

// NewBatch provides a mock function with given fields:
func (_m *BleveIndex) NewBatch() *bleve.Batch {
	ret := _m.Called()

	var r0 *bleve.Batch
	if rf, ok := ret.Get(0).(func() *bleve.Batch); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*bleve.Batch)
		}
	}

	return r0
}

// Search provides a mock function with given fields: req
func (_m *BleveIndex) Search(req *bleve.SearchRequest) (*bleve.SearchResult, error) {
	ret := _m.Called(req)

	var r0 *bleve.SearchResult
	if rf, ok := ret.Get(0).(func(*bleve.SearchRequest) *bleve.SearchResult); ok {
		r0 = rf(req)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*bleve.SearchResult)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(*bleve.SearchRequest) error); ok {
		r1 = rf(req)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// SearchInContext provides a mock function with given fields: ctx, req
func (_m *BleveIndex) SearchInContext(ctx context.Context, req *bleve.SearchRequest) (*bleve.SearchResult, error) {
	ret := _m.Called(ctx, req)

	var r0 *bleve.SearchResult
	if rf, ok := ret.Get(0).(func(context.Context, *bleve.SearchRequest) *bleve.SearchResult); ok {
		r0 = rf(ctx, req)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*bleve.SearchResult)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *bleve.SearchRequest) error); ok {
		r1 = rf(ctx, req)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// SetInternal provides a mock function with given fields: key, val
func (_m *BleveIndex) SetInternal(key []byte, val []byte) error {
	ret := _m.Called(key, val)

	var r0 error
	if rf, ok := ret.Get(0).(func([]byte, []byte) error); ok {
		r0 = rf(key, val)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// SetName provides a mock function with given fields: _a0
func (_m *BleveIndex) SetName(_a0 string) {
	_m.Called(_a0)
}

// Stats provides a mock function with given fields:
func (_m *BleveIndex) Stats() *bleve.IndexStat {
	ret := _m.Called()

	var r0 *bleve.IndexStat
	if rf, ok := ret.Get(0).(func() *bleve.IndexStat); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*bleve.IndexStat)
		}
	}

	return r0
}

// StatsMap provides a mock function with given fields:
func (_m *BleveIndex) StatsMap() map[string]interface{} {
	ret := _m.Called()

	var r0 map[string]interface{}
	if rf, ok := ret.Get(0).(func() map[string]interface{}); ok {
		r0 = rf()
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(map[string]interface{})
		}
	}

	return r0
}
