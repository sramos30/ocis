package mlogr

import (
	"errors"

	"github.com/go-logr/logr"
	plog "github.com/owncloud/ocis/v2/ocis-pkg/log"

	"github.com/rs/zerolog"
)

const debugVerbosity = 6
const traceVerbosity = 8

// New returns a logr.Logger which is implemented by the log.
func New(l *plog.Logger) logr.Logger {
	sink := logSink{
		l:         l,
		verbosity: 0,
		prefix:    "glauth",
		values:    nil,
	}

	return logr.New(sink)
}

func (l logSink) Init(info logr.RuntimeInfo) {
}

// logSink is a logr.LogSink that uses the ocis-pkg log.
type logSink struct {
	l         *plog.Logger
	verbosity int
	prefix    string
	values    []interface{}
}

func (l logSink) clone() logSink {
	out := l
	out.values = copySlice(l.values)
	return out
}

func copySlice(in []interface{}) []interface{} {
	out := make([]interface{}, len(in))
	copy(out, in)
	return out
}

// add converts a bunch of arbitrary key-value pairs into zerolog fields.
func add(e *zerolog.Event, keysAndVals []interface{}) {

	// make sure we got an even number of arguments
	if len(keysAndVals)%2 != 0 {
		e.Interface("args", keysAndVals).
			AnErr("zerologr-err", errors.New("odd number of arguments passed as key-value pairs for logging")).
			Stack()
		return
	}

	for i := 0; i < len(keysAndVals); {
		// process a key-value pair,
		// ensuring that the key is a string
		key, val := keysAndVals[i], keysAndVals[i+1]
		keyStr, isString := key.(string)
		if !isString {
			// if the key isn't a string, log additional error
			e.Interface("invalid key", key).
				AnErr("zerologr-err", errors.New("non-string key argument passed to logging, ignoring all later arguments")).
				Stack()
			return
		}
		e.Interface(keyStr, val)

		i += 2
	}
}

func (l logSink) Info(level int, msg string, kvList ...interface{}) {
	if l.Enabled(level) {
		var e *zerolog.Event
		if l.verbosity < debugVerbosity {
			e = l.l.Info()
		} else if l.verbosity < traceVerbosity {
			e = l.l.Debug()
		} else {
			e = l.l.Trace()
		}
		e.Int("verbosity", l.verbosity)
		if l.prefix != "" {
			e.Str("name", l.prefix)
		}
		add(e, l.values)
		add(e, kvList)
		e.Msg(msg)
	}
}

func (l logSink) Enabled(level int) bool {
	return true
}

func (l logSink) Error(err error, msg string, keysAndVals ...interface{}) {
	e := l.l.Error().Err(err)
	if l.prefix != "" {
		e.Str("name", l.prefix)
	}
	add(e, l.values)
	add(e, keysAndVals)
	e.Msg(msg)
}

// WithName returns a new logr.LogSink with the specified name appended. zerologr
// uses '/' characters to separate name elements.  Callers should not pass '/'
// in the provided name string, but this library does not actually enforce that.
func (l logSink) WithName(name string) logr.LogSink {
	nl := l.clone()
	if len(l.prefix) > 0 {
		nl.prefix = l.prefix + "/"
	}
	nl.prefix += name
	return nl
}
func (l logSink) WithValues(kvList ...interface{}) logr.LogSink {
	nl := l.clone()
	nl.values = append(nl.values, kvList...)
	return nl
}

var _ logr.LogSink = logSink{}
