/*
 * Copyright (C) by Klaas Freitag <freitag@owncloud.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 */

#ifndef ACTIVITYDATA_H
#define ACTIVITYDATA_H

#include <QtCore>

#include "account.h"

namespace OCC {
/**
 * @brief The ActivityLink class describes actions of an activity
 *
 * These are part of notifications which are mapped into activities.
 */

class ActivityLink
{
public:
    QString _label;
    QString _link;
    QByteArray _verb;
    bool _isPrimary;
};

/* ==================================================================== */
/**
 * @brief Activity Structure
 * @ingroup gui
 *
 * contains all the information describing a single activity.
 */

class Activity
{
public:
    using Identifier = qlonglong;
    enum Type {
        ActivityType,
        NotificationType
    };
    Activity() = default;
    explicit Activity(Type type, Identifier id, AccountPtr acc, const QString &subject, const QString &message, const QString &file, const QUrl &link, const QDateTime &dateTime, const QVector<ActivityLink> &&links = {});

    Type type() const;

    Identifier id() const;

    QString subject() const;

    QString message() const;

    QString file() const;

    QUrl link() const;

    QDateTime dateTime() const;

    QString accName() const;

    QUuid uuid() const;

    const QVector<ActivityLink> &links() const;

    bool operator==(const Activity &lhs) const;

private:
    Type _type;
    Identifier _id;
    QString _accName; /* display name of the account */
    QUuid _uuid; /* uuid of the account */
    QString _subject;
    QString _message;
    QString _file;
    QUrl _link;
    QDateTime _dateTime;

    QVector<ActivityLink> _links; /* These links are transformed into buttons that
                                   * call links as reactions on the activity */
};


/* ==================================================================== */
/**
 * @brief The ActivityList
 * @ingroup gui
 *
 * A QList based list of Activities
 */

typedef QList<Activity> ActivityList;
}

#endif // ACTIVITYDATA_H
