package provider

import (
	"context"

	gateway "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
	user "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	rpc "github.com/cs3org/go-cs3apis/cs3/rpc/v1beta1"
	provider "github.com/cs3org/go-cs3apis/cs3/storage/provider/v1beta1"
	ctxpkg "github.com/cs3org/reva/v2/pkg/ctx"
	"github.com/cs3org/reva/v2/pkg/events"
	"google.golang.org/grpc/metadata"
)

func (p *Provider) handleEvent(ev interface{}) {
	var ref *provider.Reference
	var owner *user.User
	switch e := ev.(type) {
	case events.ItemTrashed:
		p.logger.Debug().Interface("event", ev).Msg("marking document as deleted")
		err := p.indexClient.Delete(e.ID)
		if err != nil {
			p.logger.Error().Err(err).Interface("Id", e.ID).Msg("failed to remove item from index")
		}
		return
	case events.ItemRestored:
		p.logger.Debug().Interface("event", ev).Msg("marking document as restored")
		ref = e.Ref
		owner = &user.User{
			Id: e.Executant,
		}

		statRes, err := p.statResource(ref, owner)
		if err != nil {
			p.logger.Error().Err(err).Msg("failed to stat the changed resource")
			return
		}

		switch statRes.Status.Code {
		case rpc.Code_CODE_OK:
			err = p.indexClient.Restore(statRes.Info.Id)
			if err != nil {
				p.logger.Error().Err(err).Msg("failed to restore the changed resource in the index")
			}
		default:
			p.logger.Error().Interface("statRes", statRes).Msg("failed to stat the changed resource")
		}

		return
	case events.ItemMoved:
		p.logger.Debug().Interface("event", ev).Msg("resource has been moved, updating the document")
		ref = e.Ref
		owner = &user.User{
			Id: e.Executant,
		}

		statRes, err := p.statResource(ref, owner)
		if err != nil {
			p.logger.Error().Err(err).Msg("failed to stat the changed resource")
			return
		}

		switch statRes.Status.Code {
		case rpc.Code_CODE_OK:
			err = p.indexClient.Move(statRes.Info)
			if err != nil {
				p.logger.Error().Err(err).Msg("failed to restore the changed resource in the index")
			}
		default:
			p.logger.Error().Interface("statRes", statRes).Msg("failed to stat the changed resource")
		}

		return
	case events.ContainerCreated:
		ref = e.Ref
		owner = &user.User{
			Id: e.Executant,
		}
	case events.FileUploaded:
		ref = e.Ref
		owner = &user.User{
			Id: e.Executant,
		}
	case events.FileVersionRestored:
		ref = e.Ref
		owner = &user.User{
			Id: e.Executant,
		}
	default:
		// Not sure what to do here. Skip.
		return
	}
	p.logger.Debug().Interface("event", ev).Msg("resource has been changed, updating the document")

	statRes, err := p.statResource(ref, owner)
	if err != nil {
		p.logger.Error().Err(err).Msg("failed to stat the changed resource")
		return
	}
	if statRes.Status.Code != rpc.Code_CODE_OK {
		p.logger.Error().Interface("statRes", statRes).Msg("failed to stat the changed resource")
		return
	}

	err = p.indexClient.Add(ref, statRes.Info)
	if err != nil {
		p.logger.Error().Err(err).Msg("error adding updating the resource in the index")
	} else {
		p.logDocCount()
	}
}

func (p *Provider) statResource(ref *provider.Reference, owner *user.User) (*provider.StatResponse, error) {
	// Get auth
	ownerCtx := ctxpkg.ContextSetUser(context.Background(), owner)
	authRes, err := p.gwClient.Authenticate(ownerCtx, &gateway.AuthenticateRequest{
		Type:         "machine",
		ClientId:     "userid:" + owner.Id.OpaqueId,
		ClientSecret: p.machineAuthAPIKey,
	})
	if err != nil || authRes.GetStatus().GetCode() != rpc.Code_CODE_OK {
		p.logger.Error().Err(err).Interface("authRes", authRes).Msg("error using machine auth")
	}
	ownerCtx = metadata.AppendToOutgoingContext(ownerCtx, ctxpkg.TokenHeader, authRes.Token)

	// Stat changed resource resource
	return p.gwClient.Stat(ownerCtx, &provider.StatRequest{Ref: ref})
}
