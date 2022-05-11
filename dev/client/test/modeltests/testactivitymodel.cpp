
/*
 *    This software is in the public domain, furnished "as is", without technical
 *    support, and with no warranty, express or implied, as to its usefulness for
 *    any purpose.
 *
 */

#include "gui/models/activitylistmodel.h"
#include "gui/accountmanager.h"

#include "testutils/testutils.h"

#include <QTest>
#include <QAbstractItemModelTester>

namespace OCC {

class TestActivityModel : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testInsert()
    {
        auto model = new ActivityListModel(this);

        new QAbstractItemModelTester(model, this);

        auto acc1 = TestUtils::createDummyAccount();
        auto acc2 = TestUtils::createDummyAccount();

        model->setActivityList({
            Activity { Activity::ActivityType, 1, acc1, "test", "test", "foo.cpp", QUrl::fromUserInput("https://owncloud.com"), QDateTime::currentDateTime() },
            Activity { Activity::ActivityType, 2, acc1, "test", "test", "foo.cpp", QUrl::fromUserInput("https://owncloud.com"), QDateTime::currentDateTime() },
            Activity { Activity::ActivityType, 4, acc2, "test", "test", "foo.cpp", QUrl::fromUserInput("https://owncloud.com"), QDateTime::currentDateTime() },
        });
        model->setActivityList({
            Activity { Activity::ActivityType, 1, acc2, "test", "test", "foo.cpp", QUrl::fromUserInput("https://owncloud.com"), QDateTime::currentDateTime() },
            Activity { Activity::ActivityType, 2, acc1, "test", "test", "foo.cpp", QUrl::fromUserInput("https://owncloud.com"), QDateTime::currentDateTime() },
            Activity { Activity::ActivityType, 4, acc2, "test", "test", "foo.cpp", QUrl::fromUserInput("https://owncloud.com"), QDateTime::currentDateTime() },
        });
        model->slotRemoveAccount(AccountManager::instance()->accounts().first());
    }
};
}

QTEST_GUILESS_MAIN(OCC::TestActivityModel)
#include "testactivitymodel.moc"
