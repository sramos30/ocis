/*
 * Copyright (C) by Olivier Goffart <ogoffart@owncloud.com>
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
#pragma once

#include "owncloudpropagator.h"
#include "networkjobs.h"

#include <QBuffer>
#include <QFile>

namespace OCC {

class OWNCLOUDSYNC_EXPORT GETJob : public AbstractNetworkJob
{
    Q_OBJECT
protected:
    QByteArray _etag;
    time_t _lastModified = 0;
    QString _errorString;
    SyncFileItem::Status _errorStatus = SyncFileItem::NoStatus;
    bool _bandwidthLimited = false; // if _bandwidthQuota will be used
    bool _bandwidthChoked = false; // if download is paused (won't read on readyRead())
    qint64 _bandwidthQuota = 0;
    QPointer<BandwidthManager> _bandwidthManager = nullptr;

public:
    GETJob(AccountPtr account, const QUrl &rootUrl, const QString &path, QObject *parent = nullptr);

    ~GETJob() override;

    virtual qint64 currentDownloadPosition() = 0;
    virtual qint64 resumeStart() { return 0; }

    QByteArray &etag() { return _etag; }
    time_t lastModified() { return _lastModified; }

    void setErrorString(const QString &s) { _errorString = s; }
    QString errorString() const;
    SyncFileItem::Status errorStatus() { return _errorStatus; }
    void setErrorStatus(const SyncFileItem::Status &s) { _errorStatus = s; }
    void setBandwidthManager(BandwidthManager *bwm);
    void setChoked(bool c);
    void setBandwidthLimited(bool b);
    void giveBandwidthQuota(qint64 q);

signals:
    void finishedSignal();
};

/**
 * @brief Downloads the remote file via GET
 * @ingroup libsync
 */
class OWNCLOUDSYNC_EXPORT GETFileJob : public GETJob
{
    Q_OBJECT
    QIODevice *_device;
    QMap<QByteArray, QByteArray> _headers;
    QByteArray _expectedEtagForResume;
    qint64 _expectedContentLength;
    qint64 _contentLength;
    qint64 _resumeStart;
    bool _hasEmittedFinishedSignal;

    /// Will be set to true once we've seen a 2xx response header
    bool _saveBodyToFile = false;

public:
    // DOES NOT take ownership of the device.
    // For directDownloadUrl:
    explicit GETFileJob(AccountPtr account, const QUrl &url, const QString &path, QIODevice *device,
        const QMap<QByteArray, QByteArray> &headers, const QByteArray &expectedEtagForResume,
        qint64 resumeStart, QObject *parent = nullptr);

    qint64 currentDownloadPosition() override;

    void start() override;
    bool finished() override
    {
        if (_saveBodyToFile && reply()->bytesAvailable()) {
            return false;
        } else {
            if (!_hasEmittedFinishedSignal) {
                emit finishedSignal();
            }
            _hasEmittedFinishedSignal = true;
            return true; // discard
        }
    }

    void newReplyHook(QNetworkReply *reply) override;

    qint64 resumeStart() override
    {
        return _resumeStart;
    }

    qint64 contentLength() const { return _contentLength; }
    qint64 expectedContentLength() const { return _expectedContentLength; }
    void setExpectedContentLength(qint64 size) { _expectedContentLength = size; }

private slots:
    void slotReadyRead();
    void slotMetaDataChanged();

signals:
    void downloadProgress(qint64, qint64);
};

/**
 * @brief The PropagateDownloadFile class
 * @ingroup libsync
 *
 * This is the flow:

\code{.unparsed}
  start()
    +
    | deleteExistingFolder() if enabled
    |
    +--> mtime and size identical?
    |    then compute the local checksum
    |                               done?+> conflictChecksumComputed()
    |                                                                +
    |                         checksum differs?                      |
    +-> startDownload() <--------------------------------------------+
    +            +                           |                       |
    no           no                          |                       |
    +            +                           |                       |
    |            v                           |                       |
    +-> startFullDownload()                  |                       |
              +                              |                       |
              +-> run a GETFileJob           |                       | checksum identical?
                                             |                       |
          done?+> slotGetFinished() <--------+                       |
                    +                                                |
                    +-> validate checksum header                     |
                                                                     |
          done?+> transmissionChecksumValidated()                    |
                    +                                                |
                    +-> compute the content checksum                 |
                                                                     |
          done?+> contentChecksumComputed()                          |
                    +                                                |
                    +-> downloadFinished()                           |
                           +                                         |
        +------------------+                                         |
        |                                                            |
        +-> updateMetadata() <---------------------------------------+

\endcode
 */
class PropagateDownloadFile : public PropagateItemJob
{
    Q_OBJECT
    QByteArray _expectedEtagForResume;

public:
    PropagateDownloadFile(OwncloudPropagator *propagator, const SyncFileItemPtr &item)
        : PropagateItemJob(propagator, item)
        , _resumeStart(0)
        , _downloadProgress(0)
        , _deleteExisting(false)
    {
    }
    void start() override;
    qint64 committedDiskSpace() const override;

    // We think it might finish quickly because it is a small file.
    bool isLikelyFinishedQuickly() override { return _item->_size < propagator()->smallFileSize(); }

    /**
     * Whether an existing folder with the same name may be deleted before
     * the download.
     *
     * If it's a non-empty folder, it'll be renamed to a conflict-style name
     * to preserve any non-synced content that may be inside.
     *
     * Default: false.
     */
    void setDeleteExistingFolder(bool enabled);

private slots:
    /// Called when ComputeChecksum on the local file finishes,
    /// maybe the local and remote checksums are identical?
    void conflictChecksumComputed(const QByteArray &checksumType, const QByteArray &checksum);
    /// Called to start downloading the remote file
    void startDownload();
    void startFullDownload();
    /// Called when the GETJob finishes
    void slotGetFinished();
    /// Called when the download's checksum header was validated
    void transmissionChecksumValidated(const QByteArray &checksumType, const QByteArray &checksum);
    /// Called when the download's checksum computation is done
    void contentChecksumComputed(const QByteArray &checksumType, const QByteArray &checksum);
    void downloadFinished();
    /// Called when it's time to update the db metadata
    void updateMetadata(bool isConflict);

    void abort(PropagatorJob::AbortType abortType) override;
    void slotDownloadProgress(qint64, qint64);
    void slotChecksumFail(const QString &errMsg);

private:
    void deleteExistingFolder();

    qint64 _resumeStart;
    qint64 _downloadProgress;
    QPointer<GETJob> _job;
    QFile _tmpFile;
    bool _deleteExisting;
    ConflictRecord _conflictRecord;

    QElapsedTimer _stopwatch;
};
}
