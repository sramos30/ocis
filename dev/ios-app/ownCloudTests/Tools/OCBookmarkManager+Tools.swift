//
//  OCBookmarkManager+Tools.swift
//  ownCloudTests
//
//  Created by Felix Schwarz on 24.01.19.
//  Copyright © 2019 ownCloud GmbH. All rights reserved.
//

import UIKit
import ownCloudSDK
import EarlGrey

extension OCBookmarkManager {
	static func deleteAllBookmarks(waitForServerlistRefresh: Bool = false) {
		let bookmarks : [OCBookmark] = OCBookmarkManager.shared.bookmarks as [OCBookmark]

		if bookmarks.count > 0 {
			let waitGroup = DispatchGroup()

			for bookmark:OCBookmark in bookmarks {
				waitGroup.enter()

				OCCoreManager.shared.scheduleOfflineOperation({ (bookmark, completionHandler) in
					let vault : OCVault = OCVault(bookmark: bookmark)

					vault.erase(completionHandler: { (_, error) in
						if error == nil {
							OCBookmarkManager.shared.removeBookmark(bookmark)
						} else {
							assertionFailure("Error deleting vault for bookmark")
						}

						waitGroup.leave()

						completionHandler()
					})
				}, for: bookmark)
			}

			switch waitGroup.wait(timeout: .now() + 5.0) {
				case .success: break
				case .timedOut:
					let remainingBookmarks : [OCBookmark] = OCBookmarkManager.shared.bookmarks as [OCBookmark]

					for bookmark in remainingBookmarks {
						NSLog("timed out waiting for bookmark \(bookmark.uuid) to complete deletion")
						OCBookmarkManager.shared.removeBookmark(bookmark)
					}
					// assertionFailure("timed out waiting for bookmarks to complete deletion")
			}
		}

		if waitForServerlistRefresh {
			NSLog("Waiting for element addServer result: \(EarlGrey.waitForElement(accessibilityID: "addServer"))")
		}
	}
}
