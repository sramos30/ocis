//
//  OCVault+FPServices.h
//  ownCloudApp
//
//  Created by Felix Schwarz on 22.07.20.
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

NS_ASSUME_NONNULL_BEGIN

@interface OCVault (FPServices)

@property(strong,readonly) NSURL *fpServicesURL; //!< Returns the URL to use to get file provider services for this vault

@end

NS_ASSUME_NONNULL_END
