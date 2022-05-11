//
//  OCQueryCondition+SearchSegmenter.h
//  ownCloudApp
//
//  Created by Felix Schwarz on 19.03.21.
//  Copyright © 2021 ownCloud GmbH. All rights reserved.
//

/*
 * Copyright (C) 2021, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

#import <ownCloudSDK/ownCloudSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SearchSegmenter)

- (NSArray<NSString *> *)segmentedForSearchWithQuotationMarks:(BOOL)withQuotationMarks;

@end

@interface OCQueryCondition (SearchSegmenter)

+ (nullable instancetype)forSearchSegment:(NSString *)segmentString;
+ (nullable instancetype)fromSearchTerm:(NSString *)searchTerm;

@end

NS_ASSUME_NONNULL_END
