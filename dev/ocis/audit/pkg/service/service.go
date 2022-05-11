package svc

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/cs3org/reva/v2/pkg/events"
	"github.com/owncloud/ocis/audit/pkg/config"
	"github.com/owncloud/ocis/audit/pkg/types"
	"github.com/owncloud/ocis/ocis-pkg/log"
)

// Log is used to log to different outputs
type Log func([]byte)

// Marshaller is used to marshal events
type Marshaller func(interface{}) ([]byte, error)

// AuditLoggerFromConfig will start a new AuditLogger generated from the config
func AuditLoggerFromConfig(ctx context.Context, cfg config.Auditlog, ch <-chan interface{}, log log.Logger) {
	var logs []Log

	if cfg.LogToConsole {
		logs = append(logs, WriteToStdout())
	}

	if cfg.LogToFile {
		logs = append(logs, WriteToFile(cfg.FilePath, log))
	}

	StartAuditLogger(ctx, ch, log, Marshal(cfg.Format, log), logs...)

}

// StartAuditLogger will block. run in seperate go routine
func StartAuditLogger(ctx context.Context, ch <-chan interface{}, log log.Logger, marshaller Marshaller, logto ...Log) {
	for {
		select {
		case <-ctx.Done():
			return
		case i := <-ch:
			var auditEvent interface{}
			switch ev := i.(type) {
			case events.ShareCreated:
				auditEvent = types.ShareCreated(ev)
			case events.LinkCreated:
				auditEvent = types.LinkCreated(ev)
			case events.ShareUpdated:
				auditEvent = types.ShareUpdated(ev)
			case events.LinkUpdated:
				auditEvent = types.LinkUpdated(ev)
			case events.ShareRemoved:
				auditEvent = types.ShareRemoved(ev)
			case events.LinkRemoved:
				auditEvent = types.LinkRemoved(ev)
			case events.ReceivedShareUpdated:
				auditEvent = types.ReceivedShareUpdated(ev)
			case events.LinkAccessed:
				auditEvent = types.LinkAccessed(ev)
			case events.LinkAccessFailed:
				auditEvent = types.LinkAccessFailed(ev)
			case events.FileUploaded:
				auditEvent = types.FileUploaded(ev)
			case events.FileDownloaded:
				auditEvent = types.FileDownloaded(ev)
			case events.ItemMoved:
				auditEvent = types.ItemMoved(ev)
			case events.ItemTrashed:
				auditEvent = types.ItemTrashed(ev)
			case events.ItemPurged:
				auditEvent = types.ItemPurged(ev)
			case events.ItemRestored:
				auditEvent = types.ItemRestored(ev)
			case events.FileVersionRestored:
				auditEvent = types.FileVersionRestored(ev)
			case events.SpaceCreated:
				auditEvent = types.SpaceCreated(ev)
			case events.SpaceRenamed:
				auditEvent = types.SpaceRenamed(ev)
			case events.SpaceDisabled:
				auditEvent = types.SpaceDisabled(ev)
			case events.SpaceEnabled:
				auditEvent = types.SpaceEnabled(ev)
			case events.SpaceDeleted:
				auditEvent = types.SpaceDeleted(ev)
			default:
				log.Error().Interface("event", ev).Msg(fmt.Sprintf("can't handle event of type '%T'", ev))
				continue

			}

			b, err := marshaller(auditEvent)
			if err != nil {
				log.Error().Err(err).Msg("error marshaling the event")
				continue
			}

			for _, l := range logto {
				l(b)
			}
		}
	}

}

// WriteToFile returns a Log function writing to a file
func WriteToFile(path string, log log.Logger) Log {
	return func(content []byte) {
		file, err := os.OpenFile(path, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
		if err != nil {
			log.Error().Err(err).Msgf("error opening file '%s'", path)
			return
		}
		defer file.Close()
		if _, err := fmt.Fprintln(file, string(content)); err != nil {
			log.Error().Err(err).Msgf("error writing to file '%s'", path)
		}
	}
}

// WriteToStdout return a Log function writing to Stdout
func WriteToStdout() Log {
	return func(content []byte) {
		fmt.Println(string(content))
	}
}

// Marshal returns a Marshaller from the `format` string
func Marshal(format string, log log.Logger) Marshaller {
	switch format {
	default:
		log.Error().Msgf("unknown format '%s'", format)
		return nil
	case "json":
		return json.Marshal
	case "minimal":
		return func(ev interface{}) ([]byte, error) {
			b, err := json.Marshal(ev)
			if err != nil {
				return nil, err
			}

			m := make(map[string]interface{})
			if err := json.Unmarshal(b, &m); err != nil {
				return nil, err
			}

			format := fmt.Sprintf("%s)\n   %s", m["Action"], m["Message"])
			return []byte(format), nil
		}
	}
}
