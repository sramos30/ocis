#include "configfile.h"
#include "logger.h"

#include <QCoreApplication>
#include <QTemporaryDir>

namespace {
void setupLogger()
{
    static QTemporaryDir dir;
    OCC::ConfigFile::setConfDir(dir.path()); // we don't want to pollute the user's config file

    OCC::Logger::instance()->setLogFile(QStringLiteral("-"));
    OCC::Logger::instance()->addLogRule({ QStringLiteral("sync.httplogger=true") });
    OCC::Logger::instance()->setLogDebug(true);
}
Q_COREAPP_STARTUP_FUNCTION(setupLogger);
}
