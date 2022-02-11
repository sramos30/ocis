// Code generated by mockery v2.9.4. DO NOT EDIT.

package mocks

import (
	context "context"

	gatewayv1beta1 "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
	grpc "google.golang.org/grpc"

	mock "github.com/stretchr/testify/mock"

	providerv1beta1 "github.com/cs3org/go-cs3apis/cs3/storage/provider/v1beta1"
)

// GatewayClient is an autogenerated mock type for the GatewayClient type
type GatewayClient struct {
	mock.Mock
}

// CreateStorageSpace provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) CreateStorageSpace(ctx context.Context, in *providerv1beta1.CreateStorageSpaceRequest, opts ...grpc.CallOption) (*providerv1beta1.CreateStorageSpaceResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.CreateStorageSpaceResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.CreateStorageSpaceRequest, ...grpc.CallOption) *providerv1beta1.CreateStorageSpaceResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.CreateStorageSpaceResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.CreateStorageSpaceRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// DeleteStorageSpace provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) DeleteStorageSpace(ctx context.Context, in *providerv1beta1.DeleteStorageSpaceRequest, opts ...grpc.CallOption) (*providerv1beta1.DeleteStorageSpaceResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.DeleteStorageSpaceResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.DeleteStorageSpaceRequest, ...grpc.CallOption) *providerv1beta1.DeleteStorageSpaceResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.DeleteStorageSpaceResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.DeleteStorageSpaceRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// GetHome provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) GetHome(ctx context.Context, in *providerv1beta1.GetHomeRequest, opts ...grpc.CallOption) (*providerv1beta1.GetHomeResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.GetHomeResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.GetHomeRequest, ...grpc.CallOption) *providerv1beta1.GetHomeResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.GetHomeResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.GetHomeRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// GetPath provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) GetPath(ctx context.Context, in *providerv1beta1.GetPathRequest, opts ...grpc.CallOption) (*providerv1beta1.GetPathResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.GetPathResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.GetPathRequest, ...grpc.CallOption) *providerv1beta1.GetPathResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.GetPathResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.GetPathRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// GetQuota provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) GetQuota(ctx context.Context, in *gatewayv1beta1.GetQuotaRequest, opts ...grpc.CallOption) (*providerv1beta1.GetQuotaResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.GetQuotaResponse
	if rf, ok := ret.Get(0).(func(context.Context, *gatewayv1beta1.GetQuotaRequest, ...grpc.CallOption) *providerv1beta1.GetQuotaResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.GetQuotaResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *gatewayv1beta1.GetQuotaRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// InitiateFileDownload provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) InitiateFileDownload(ctx context.Context, in *providerv1beta1.InitiateFileDownloadRequest, opts ...grpc.CallOption) (*gatewayv1beta1.InitiateFileDownloadResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *gatewayv1beta1.InitiateFileDownloadResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.InitiateFileDownloadRequest, ...grpc.CallOption) *gatewayv1beta1.InitiateFileDownloadResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*gatewayv1beta1.InitiateFileDownloadResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.InitiateFileDownloadRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// ListContainer provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) ListContainer(ctx context.Context, in *providerv1beta1.ListContainerRequest, opts ...grpc.CallOption) (*providerv1beta1.ListContainerResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.ListContainerResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.ListContainerRequest, ...grpc.CallOption) *providerv1beta1.ListContainerResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.ListContainerResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.ListContainerRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// ListStorageSpaces provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) ListStorageSpaces(ctx context.Context, in *providerv1beta1.ListStorageSpacesRequest, opts ...grpc.CallOption) (*providerv1beta1.ListStorageSpacesResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.ListStorageSpacesResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.ListStorageSpacesRequest, ...grpc.CallOption) *providerv1beta1.ListStorageSpacesResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.ListStorageSpacesResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.ListStorageSpacesRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Stat provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) Stat(ctx context.Context, in *providerv1beta1.StatRequest, opts ...grpc.CallOption) (*providerv1beta1.StatResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.StatResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.StatRequest, ...grpc.CallOption) *providerv1beta1.StatResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.StatResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.StatRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// UpdateStorageSpace provides a mock function with given fields: ctx, in, opts
func (_m *GatewayClient) UpdateStorageSpace(ctx context.Context, in *providerv1beta1.UpdateStorageSpaceRequest, opts ...grpc.CallOption) (*providerv1beta1.UpdateStorageSpaceResponse, error) {
	_va := make([]interface{}, len(opts))
	for _i := range opts {
		_va[_i] = opts[_i]
	}
	var _ca []interface{}
	_ca = append(_ca, ctx, in)
	_ca = append(_ca, _va...)
	ret := _m.Called(_ca...)

	var r0 *providerv1beta1.UpdateStorageSpaceResponse
	if rf, ok := ret.Get(0).(func(context.Context, *providerv1beta1.UpdateStorageSpaceRequest, ...grpc.CallOption) *providerv1beta1.UpdateStorageSpaceResponse); ok {
		r0 = rf(ctx, in, opts...)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*providerv1beta1.UpdateStorageSpaceResponse)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, *providerv1beta1.UpdateStorageSpaceRequest, ...grpc.CallOption) error); ok {
		r1 = rf(ctx, in, opts...)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}
