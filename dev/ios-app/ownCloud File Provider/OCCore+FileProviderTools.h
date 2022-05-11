//
//  OCCore+FileProviderTools.h
//  ownCloud File Provider
//
//  Created by Felix Schwarz on 09.06.18.
//  Copyright © 2018 ownCloud GmbH. All rights reserved.
//

/*
 * Copyright (C) 2018, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

#import <ownCloudSDK/ownCloudSDK.h>
#import <ownCloudSDK/OCMacros.h>

@interface OCCore (FileProviderTools)

- (OCItem *)synchronousRetrieveItemFromDatabaseForLocalID:(OCLocalID)localID syncAnchor:(OCSyncAnchor __autoreleasing *)outSyncAnchor error:(NSError * __autoreleasing *)outError;

@end
