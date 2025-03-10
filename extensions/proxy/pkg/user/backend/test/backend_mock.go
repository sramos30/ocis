// Code generated by moq; DO NOT EDIT.
// github.com/matryer/moq

package test

import (
	"context"
	"sync"

	userv1beta1 "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	"github.com/owncloud/ocis/v2/extensions/proxy/pkg/user/backend"
)

// Ensure, that UserBackendMock does implement UserBackend.
// If this is not the case, regenerate this file with moq.
var _ backend.UserBackend = &UserBackendMock{}

// UserBackendMock is a mock implementation of UserBackend.
//
//     func TestSomethingThatUsesUserBackend(t *testing.T) {
//
//         // make and configure a mocked UserBackend
//         mockedUserBackend := &UserBackendMock{
//             AuthenticateFunc: func(ctx context.Context, username string, password string) (*userv1beta1.User, error) {
// 	               panic("mock out the Authenticate method")
//             },
//             CreateUserFromClaimsFunc: func(ctx context.Context, claims *oidc.StandardClaims) (*userv1beta1.User, error) {
// 	               panic("mock out the CreateUserFromClaims method")
//             },
//             GetUserByClaimsFunc: func(ctx context.Context, claim string, value string, withRoles bool) (*userv1beta1.User, error) {
// 	               panic("mock out the GetUserByClaims method")
//             },
//             GetUserGroupsFunc: func(ctx context.Context, userID string)  {
// 	               panic("mock out the GetUserGroups method")
//             },
//         }
//
//         // use mockedUserBackend in code that requires UserBackend
//         // and then make assertions.
//
//     }
type UserBackendMock struct {
	// AuthenticateFunc mocks the Authenticate method.
	AuthenticateFunc func(ctx context.Context, username string, password string) (*userv1beta1.User, string, error)

	// CreateUserFromClaimsFunc mocks the CreateUserFromClaims method.
	CreateUserFromClaimsFunc func(ctx context.Context, claims map[string]interface{}) (*userv1beta1.User, error)

	// GetUserByClaimsFunc mocks the GetUserByClaims method.
	GetUserByClaimsFunc func(ctx context.Context, claim string, value string, withRoles bool) (*userv1beta1.User, string, error)

	// GetUserGroupsFunc mocks the GetUserGroups method.
	GetUserGroupsFunc func(ctx context.Context, userID string)

	// calls tracks calls to the methods.
	calls struct {
		// Authenticate holds details about calls to the Authenticate method.
		Authenticate []struct {
			// Ctx is the ctx argument value.
			Ctx context.Context
			// Username is the username argument value.
			Username string
			// Password is the password argument value.
			Password string
		}
		// CreateUserFromClaims holds details about calls to the CreateUserFromClaims method.
		CreateUserFromClaims []struct {
			// Ctx is the ctx argument value.
			Ctx context.Context
			// Claims is the claims argument value.
			Claims map[string]interface{}
		}
		// GetUserByClaims holds details about calls to the GetUserByClaims method.
		GetUserByClaims []struct {
			// Ctx is the ctx argument value.
			Ctx context.Context
			// Claim is the claim argument value.
			Claim string
			// Value is the value argument value.
			Value string
			// WithRoles is the withRoles argument value.
			WithRoles bool
		}
		// GetUserGroups holds details about calls to the GetUserGroups method.
		GetUserGroups []struct {
			// Ctx is the ctx argument value.
			Ctx context.Context
			// UserID is the userID argument value.
			UserID string
		}
	}
	lockAuthenticate         sync.RWMutex
	lockCreateUserFromClaims sync.RWMutex
	lockGetUserByClaims      sync.RWMutex
	lockGetUserGroups        sync.RWMutex
}

// Authenticate calls AuthenticateFunc.
func (mock *UserBackendMock) Authenticate(ctx context.Context, username string, password string) (*userv1beta1.User, string, error) {
	if mock.AuthenticateFunc == nil {
		panic("UserBackendMock.AuthenticateFunc: method is nil but UserBackend.Authenticate was just called")
	}
	callInfo := struct {
		Ctx      context.Context
		Username string
		Password string
	}{
		Ctx:      ctx,
		Username: username,
		Password: password,
	}
	mock.lockAuthenticate.Lock()
	mock.calls.Authenticate = append(mock.calls.Authenticate, callInfo)
	mock.lockAuthenticate.Unlock()
	return mock.AuthenticateFunc(ctx, username, password)
}

// AuthenticateCalls gets all the calls that were made to Authenticate.
// Check the length with:
//     len(mockedUserBackend.AuthenticateCalls())
func (mock *UserBackendMock) AuthenticateCalls() []struct {
	Ctx      context.Context
	Username string
	Password string
} {
	var calls []struct {
		Ctx      context.Context
		Username string
		Password string
	}
	mock.lockAuthenticate.RLock()
	calls = mock.calls.Authenticate
	mock.lockAuthenticate.RUnlock()
	return calls
}

// CreateUserFromClaims calls CreateUserFromClaimsFunc.
func (mock *UserBackendMock) CreateUserFromClaims(ctx context.Context, claims map[string]interface{}) (*userv1beta1.User, error) {
	if mock.CreateUserFromClaimsFunc == nil {
		panic("UserBackendMock.CreateUserFromClaimsFunc: method is nil but UserBackend.CreateUserFromClaims was just called")
	}
	callInfo := struct {
		Ctx    context.Context
		Claims map[string]interface{}
	}{
		Ctx:    ctx,
		Claims: claims,
	}
	mock.lockCreateUserFromClaims.Lock()
	mock.calls.CreateUserFromClaims = append(mock.calls.CreateUserFromClaims, callInfo)
	mock.lockCreateUserFromClaims.Unlock()
	return mock.CreateUserFromClaimsFunc(ctx, claims)
}

// CreateUserFromClaimsCalls gets all the calls that were made to CreateUserFromClaims.
// Check the length with:
//     len(mockedUserBackend.CreateUserFromClaimsCalls())
func (mock *UserBackendMock) CreateUserFromClaimsCalls() []struct {
	Ctx    context.Context
	Claims map[string]interface{}
} {
	var calls []struct {
		Ctx    context.Context
		Claims map[string]interface{}
	}
	mock.lockCreateUserFromClaims.RLock()
	calls = mock.calls.CreateUserFromClaims
	mock.lockCreateUserFromClaims.RUnlock()
	return calls
}

// GetUserByClaims calls GetUserByClaimsFunc.
func (mock *UserBackendMock) GetUserByClaims(ctx context.Context, claim string, value string, withRoles bool) (*userv1beta1.User, string, error) {
	if mock.GetUserByClaimsFunc == nil {
		panic("UserBackendMock.GetUserByClaimsFunc: method is nil but UserBackend.GetUserByClaims was just called")
	}
	callInfo := struct {
		Ctx       context.Context
		Claim     string
		Value     string
		WithRoles bool
	}{
		Ctx:       ctx,
		Claim:     claim,
		Value:     value,
		WithRoles: withRoles,
	}
	mock.lockGetUserByClaims.Lock()
	mock.calls.GetUserByClaims = append(mock.calls.GetUserByClaims, callInfo)
	mock.lockGetUserByClaims.Unlock()
	return mock.GetUserByClaimsFunc(ctx, claim, value, withRoles)
}

// GetUserByClaimsCalls gets all the calls that were made to GetUserByClaims.
// Check the length with:
//     len(mockedUserBackend.GetUserByClaimsCalls())
func (mock *UserBackendMock) GetUserByClaimsCalls() []struct {
	Ctx       context.Context
	Claim     string
	Value     string
	WithRoles bool
} {
	var calls []struct {
		Ctx       context.Context
		Claim     string
		Value     string
		WithRoles bool
	}
	mock.lockGetUserByClaims.RLock()
	calls = mock.calls.GetUserByClaims
	mock.lockGetUserByClaims.RUnlock()
	return calls
}

// GetUserGroups calls GetUserGroupsFunc.
func (mock *UserBackendMock) GetUserGroups(ctx context.Context, userID string) {
	if mock.GetUserGroupsFunc == nil {
		panic("UserBackendMock.GetUserGroupsFunc: method is nil but UserBackend.GetUserGroups was just called")
	}
	callInfo := struct {
		Ctx    context.Context
		UserID string
	}{
		Ctx:    ctx,
		UserID: userID,
	}
	mock.lockGetUserGroups.Lock()
	mock.calls.GetUserGroups = append(mock.calls.GetUserGroups, callInfo)
	mock.lockGetUserGroups.Unlock()
	mock.GetUserGroupsFunc(ctx, userID)
}

// GetUserGroupsCalls gets all the calls that were made to GetUserGroups.
// Check the length with:
//     len(mockedUserBackend.GetUserGroupsCalls())
func (mock *UserBackendMock) GetUserGroupsCalls() []struct {
	Ctx    context.Context
	UserID string
} {
	var calls []struct {
		Ctx    context.Context
		UserID string
	}
	mock.lockGetUserGroups.RLock()
	calls = mock.calls.GetUserGroups
	mock.lockGetUserGroups.RUnlock()
	return calls
}
