//
//  OCLicenseProvider.h
//  ownCloudApp
//
//  Created by Felix Schwarz on 29.10.19.
//  Copyright © 2019 ownCloud GmbH. All rights reserved.
//

/*
 * Copyright (C) 2019, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

#import <Foundation/Foundation.h>
#import "OCLicenseTypes.h"

@class OCLicenseManager;
@class OCLicenseOffer;
@class OCLicenseEntitlement;
@class OCLicenseProvider;
@class OCLicenseTransaction;

NS_ASSUME_NONNULL_BEGIN

typedef void(^OCLicenseProviderCompletionHandler)(OCLicenseProvider *provider, NSError * _Nullable error);

@interface OCLicenseProvider : NSObject

@property(weak,nullable) OCLicenseManager *manager;

- (instancetype)initWithIdentifier:(OCLicenseProviderIdentifier)identifier;

#pragma mark - Metadata
@property(strong) OCLicenseProviderIdentifier identifier; //!< Identifier uniquely identifying this license provider
@property(strong,nullable) NSString *localizedName; //!< (optional) localized name of the license provider

#pragma mark - Storage
@property(strong,nonatomic,nullable) NSURL *storageURL; //!< If .manager is not nil, URL pointing to a filesystem location where the provider can persist/cache its data.
@property(strong,nonatomic,nullable) NSData *storedData; //!< Convenience wrapper that loads/saves data from/to .storageURL

#pragma mark - Payload
@property(strong,nonatomic,nullable) NSArray <OCLicenseOffer *> *offers; //!< Offers made available by the provider. Updates to this property trigger updates in OCLicenseManager.
@property(strong,nonatomic,nullable) NSArray <OCLicenseEntitlement *> *entitlements; //!< Entitlements found by the provider. Updates to this property trigger updates in OCLicenseManager.

#pragma mark - Transaction access
- (void)retrieveTransactionsWithCompletionHandler:(void(^)(NSError * _Nullable error, NSArray <OCLicenseTransaction *> * _Nullable transactions))completionHandler; //!< Retrieve transactions

#pragma mark - IAP Messages
- (nullable NSString *)inAppPurchaseMessageForFeature:(nullable OCLicenseFeatureIdentifier)featureIdentifier; //!< (optional) Message to be shown above IAPs for the identified feature. (consolidated)

#pragma mark - Control
- (void)startProvidingWithCompletionHandler:(OCLicenseProviderCompletionHandler)completionHandler; //!< Called when the provider should start providing payloads
- (void)stopProvidingWithCompletionHandler:(OCLicenseProviderCompletionHandler)completionHandler; //!< Called when the provider should stop providing payloads

@end

extern NSNotificationName OCLicenseProviderInAppPurchaseMessageChangedNotification; //!< Notification to be sent when the in-app purchase message should be re-requested

NS_ASSUME_NONNULL_END
