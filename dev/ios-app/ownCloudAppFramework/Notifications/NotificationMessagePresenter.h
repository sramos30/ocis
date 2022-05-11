//
//  NotificationMessagePresenter.h
//  ownCloud
//
//  Created by Felix Schwarz on 26.03.20.
//  Copyright © 2020 ownCloud GmbH. All rights reserved.
//

/*
 * Copyright (C) 2020, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

#import <ownCloudSDK/ownCloudSDK.h>
#import "NotificationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationMessagePresenter : OCMessagePresenter <NotificationResponseHandler>

@property(strong,readonly) OCBookmarkUUID bookmarkUUID;

- (instancetype)initForBookmarkUUID:(OCBookmarkUUID)bookmarkUUID;

@end

extern NSNotificationName NotificationMessagePresenterShowMessageNotification; //!< Posted if a user taps on a notification, with the OCMessage as Notification.object

NS_ASSUME_NONNULL_END
