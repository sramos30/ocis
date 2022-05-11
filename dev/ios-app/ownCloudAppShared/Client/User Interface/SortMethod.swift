//
//  SortMethod.swift
//  ownCloud
//
//  Created by Pablo Carrascal on 23/05/2018.
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

import Foundation
import ownCloudSDK
import ownCloudApp

public typealias OCSort = Comparator

public enum SortDirection: Int {
	case ascendant = 0
	case descendant = 1
}

public enum SortMethod: Int {

	case alphabetically = 0
	case kind = 1
	case size = 2
	case date = 3
	case shared = 4

	public static var all: [SortMethod] = [alphabetically, kind, size, date, shared]

	public var localizedName : String {
		var name = ""

		switch self {
			case .alphabetically:
				name = "name".localized
			case .kind:
				name = "kind".localized
			case .size:
				name = "size".localized
			case .date:
				name = "date".localized
			case .shared:
				name = "shared".localized
		}

		return name
	}

	public var sortPropertyName : OCItemPropertyName? {
		var propertyName : OCItemPropertyName?

		switch self {
			case .alphabetically:
				propertyName = .name
			case .kind:
				propertyName = .mimeType
			case .size:
				propertyName = .size
			case .date:
				propertyName = .lastModified
			case .shared: break
		}

		return propertyName
	}

	public func comparator(direction: SortDirection) -> OCSort {
		var comparator: OCSort
		var combinedComparator: OCSort?
		let localizedSortComparator = OCSQLiteCollationLocalized.sortComparator!

		let alphabeticComparator : OCSort = { (left, right) in
			guard let leftName  = (left as? OCItem)?.name, let rightName = (right as? OCItem)?.name else {
				return .orderedSame
			}
			if direction == .descendant {
				return localizedSortComparator(rightName, leftName)
			}

			return localizedSortComparator(leftName, rightName)
		}

		let itemTypeComparator : OCSort = { (left, right) in
			let leftItem = left as? OCItem
			let rightItem = right as? OCItem

			if let leftItemType = leftItem?.type, let rightItemType = rightItem?.type {
				if leftItemType != rightItemType {
					if leftItemType == .collection, rightItemType == .file {
						return .orderedAscending
					} else {
						return .orderedDescending
					}
				}
			}

			return .orderedSame
		}

		switch self {
		case .size:
			comparator = { (left, right) in
				let leftItem = left as? OCItem
				let rightItem = right as? OCItem

				let leftSize = leftItem!.size as NSNumber
				let rightSize = rightItem!.size as NSNumber
				if direction == .descendant {
					return leftSize.compare(rightSize)
				}

				return rightSize.compare(leftSize)
			}
		case .alphabetically:
			comparator = alphabeticComparator
		case .kind:
			comparator = { (left, right) in
				let leftItem = left as? OCItem
				let rightItem = right as? OCItem

				let leftKind = leftItem?.fileExtension ?? leftItem?.mimeType ?? "_various"
				let rightKind = rightItem?.fileExtension ?? rightItem?.mimeType ?? "_various"

				var result : ComparisonResult = leftKind.compare(rightKind)

				let typeResult = itemTypeComparator(left, right)

				if typeResult != .orderedSame {
					result = typeResult
				}

				if direction == .descendant {
					if result == .orderedDescending {
						result = .orderedAscending
					} else if result == .orderedAscending {
						result = .orderedDescending
					}
				}

				return result
			}
		case .shared:
			comparator = { (left, right) in
				guard let leftItem = left as? OCItem else { return .orderedSame }
				guard let rightItem = right as? OCItem else { return .orderedSame }

				let leftShared = leftItem.isSharedWithUser || leftItem.isShared
				let rightShared = rightItem.isSharedWithUser || rightItem.isShared

				if leftShared == rightShared {
					return .orderedSame
				}

				if direction == .descendant {
					 if rightShared {
						return .orderedAscending
					}

					return .orderedDescending
				} else {
					if leftShared {
						return .orderedAscending
					}

					return .orderedDescending
				}
			}
		case .date:
			comparator = { (left, right) in

				guard let leftLastModified  = (left as? OCItem)?.lastModified, let rightLastModified = (right as? OCItem)?.lastModified else {
					return .orderedSame
				}
				if direction == .descendant {
					return leftLastModified.compare(rightLastModified)
				}

				return rightLastModified.compare(leftLastModified)
			}
		}

		if combinedComparator == nil {
			combinedComparator = { (left, right) in
				var result : ComparisonResult = .orderedSame

				if DisplaySettings.shared.sortFoldersFirst {
					result = itemTypeComparator(left, right)
				}

				if result == .orderedSame {
					result = comparator(left, right)

					if result == .orderedSame, self != .alphabetically {
						result = alphabeticComparator(left, right)
					}
				}

				return result
			}
		}

		return combinedComparator ?? comparator
	}
}
