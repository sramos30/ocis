//
//  OCCore+Extension.swift
//  ownCloud
//
//  Created by Matthias Hühne on 17.04.19.
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

import Foundation
import ownCloudSDK

extension OCCore {

	public func unifiedShares(for item: OCItem, completionHandler: @escaping (_ shares: [OCShare]) -> Void) {
		let combinedShares : NSMutableArray = NSMutableArray()
		let dispatchGroup = DispatchGroup()

		if let shareQuery = OCShareQuery(scope: .itemWithReshares, item: item) {
			dispatchGroup.enter()

			shareQuery.initialPopulationHandler = { [weak self] query in
				combinedShares.addObjects(from: query.queryResults)
				dispatchGroup.leave()
				self?.stop(query)
			}
			start(shareQuery)
		}

		if let shareQuery = OCShareQuery(scope: .sharedWithUser, item: nil) {
			dispatchGroup.enter()

			shareQuery.initialPopulationHandler = { [weak self] query in
				let sharesWithMe = query.queryResults.filter({ (share) -> Bool in
					return share.itemPath == item.path
				})

				combinedShares.addObjects(from: sharesWithMe)
				dispatchGroup.leave()
				self?.stop(query)
			}
			start(shareQuery)
		}

		if let shareQuery = OCShareQuery(scope: .acceptedCloudShares, item: item) {
			dispatchGroup.enter()

			shareQuery.initialPopulationHandler = { [weak self] query in
				combinedShares.addObjects(from: query.queryResults)
				dispatchGroup.leave()
				self?.stop(query)
			}
			start(shareQuery)
		}

		dispatchGroup.notify(queue: .main, execute: {
			completionHandler((combinedShares as? [OCShare])!)
		})
	}

	@discardableResult private func retrieveShares(for item: OCItem, scope: OCShareScope, initialPopulationHandler: @escaping (_ shares: [OCShare]) -> Void, allowPartialMatch : Bool = false, keepRunning: Bool = false) -> OCShareQuery? {
		if let shareQuery = OCShareQuery(scope: scope, item: nil) {
			shareQuery.initialPopulationHandler = { [weak self] query in
				let shares = query.queryResults.filter({ (share) -> Bool in
					return (share.itemPath == item.path) ||
					       (allowPartialMatch && (item.path?.hasPrefix(share.itemPath) == true))
				})
				initialPopulationHandler(shares)

				if !keepRunning {
					self?.stop(query)
				}
			}
			start(shareQuery)

			return keepRunning ? shareQuery : nil
		}

		return nil
	}

	@discardableResult public func sharesSharedWithMe(for item: OCItem, initialPopulationHandler: @escaping (_ shares: [OCShare]) -> Void, allowPartialMatch : Bool = false, keepRunning: Bool = false) -> OCShareQuery? {
		return retrieveShares(for: item, scope: .sharedWithUser, initialPopulationHandler: initialPopulationHandler, allowPartialMatch: allowPartialMatch, keepRunning: keepRunning)
	}

	@discardableResult public func acceptedCloudShares(for item: OCItem, initialPopulationHandler: @escaping (_ shares: [OCShare]) -> Void, allowPartialMatch : Bool = false, keepRunning: Bool = false) -> OCShareQuery? {
		return retrieveShares(for: item, scope: .acceptedCloudShares, initialPopulationHandler: initialPopulationHandler, allowPartialMatch: allowPartialMatch, keepRunning: keepRunning)
	}

	@discardableResult public func sharesWithReshares(for item: OCItem, initialPopulationHandler: @escaping (_ shares: [OCShare]) -> Void, changesAvailableNotificationHandler: @escaping (_ shares: [OCShare]) -> Void, keepRunning: Bool) -> OCShareQuery? {
		if let shareQuery = OCShareQuery(scope: .itemWithReshares, item: item) {
			shareQuery.initialPopulationHandler = { [weak self] query in
				initialPopulationHandler(query.queryResults)

				if !keepRunning {
					self?.stop(query)
				}
			}
			shareQuery.changesAvailableNotificationHandler = { query in
				changesAvailableNotificationHandler(query.queryResults)
			}
			start(shareQuery)

			return keepRunning ? shareQuery : nil
		}

		return nil
	}

	public func retrieveParentItems(for item: OCItem) -> [OCItem] {
		var parentItems : [OCItem] = []

		if item.parentLocalID != nil {
			if let parentItem = item.parentItem(from: self) {
				if item.parentLocalID != nil {
					parentItems.append(parentItem)
					let items = self.retrieveParentItems(for: parentItem)
					parentItems.append(contentsOf: items.reversed())
				}
			}
		}

		return parentItems.reversed()
	}
}
