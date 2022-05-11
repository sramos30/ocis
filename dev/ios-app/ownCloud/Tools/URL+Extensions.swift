//
//  URL+Extensions.swift
//  ownCloud
//
//  Created by Michael Neuwert on 06.08.2019.
//  Copyright © 2019 ownCloud GmbH. All rights reserved.
//

import Foundation
import ownCloudSDK
import ownCloudAppShared

typealias UploadHandler = (OCItem?, Error?) -> Void

extension URL {
	var matchesAppScheme : Bool {
		guard
			let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [Any],
			let firstUrlType = urlTypes.first as? [String : Any],
			let urlSchemes = firstUrlType["CFBundleURLSchemes"] as? [String]  else {
				return false
		}
		if urlSchemes.first == self.scheme?.lowercased() {
			return true
		}
		return false
	}

	func upload(with core:OCCore?, at rootItem:OCItem, alternativeName:String? = nil, modificationDate:Date? = nil, importByCopy:Bool = false, cellularSwitchIdentifier:OCCellularSwitchIdentifier? = nil, placeholderHandler:UploadHandler? = nil, completionHandler:UploadHandler? = nil) -> Progress? {
		let fileName = alternativeName != nil ? alternativeName! : self.lastPathComponent
		var importOptions : [OCCoreOption : Any] = [.importByCopying : importByCopy, .automaticConflictResolutionNameStyle : OCCoreDuplicateNameStyle.bracketed.rawValue]

		if cellularSwitchIdentifier != nil {
			importOptions[.dependsOnCellularSwitch] = cellularSwitchIdentifier
		}

		if let modificationDate = modificationDate {
			importOptions[.lastModifiedDate] = modificationDate
		}

		var progress:Progress?

		if core != nil {
			progress = core?.importFileNamed(fileName,
											 at: rootItem,
											 from: self,
											 isSecurityScoped: false,
											 options: importOptions,
											 placeholderCompletionHandler: { (error, item) in
												if error != nil {
													Log.error("Error creating placeholder item for \(Log.mask(fileName)), error: \(error!.localizedDescription)")
												}
												placeholderHandler?(item, error)

			}, resultHandler: { (error, _, item, _) in
				if error != nil {
					Log.error("Error uploading \(Log.mask(fileName)) to \(Log.mask(rootItem.path)), error: \(error?.localizedDescription ?? "" )")
				} else {
					Log.debug("Success uploading \(Log.mask(fileName)) to \(Log.mask(rootItem.path))")
				}
				completionHandler?(item, error)
			})
		} else {
			completionHandler?(nil, NSError(ocError: .internal))
		}

		return progress
	}

	func privateLinkItemID() -> String? {

		// Check if the link URL has format https://<server>/f/<item_id>
		if self.pathComponents.count > 2 {
			if self.pathComponents[self.pathComponents.count - 2] == "f" {
				return self.pathComponents.last
			}
		}

		return nil
	}

	@discardableResult func retrieveLinkedItem(with completion: @escaping (_ item:OCItem?, _ bookmark:OCBookmark?, _ error:Error?, _ connected:Bool) -> Void) -> Bool {
		// Check if the link is private ones and has item ID
		guard self.privateLinkItemID() != nil else {
			return false
		}

		// Find matching bookmarks
		let bookmarks = OCBookmarkManager.shared.bookmarks.filter({$0.url?.host == self.host})

		var matchedBookmark: OCBookmark?
		var foundItem: OCItem?
		var lastError: Error?
		var internetReachable = false

		let group = DispatchGroup()

		for bookmark in bookmarks {

			if foundItem == nil {
				var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
				// E.g. if we would like to use app URL scheme (owncloud://) instead of universal link, to make it work with oC SDK, we need to change scheme back to the original bookmark URL scheme
				components?.scheme = bookmark.url?.scheme

				if let privateLinkURL = components?.url {
					group.enter()
					OCCoreManager.shared.requestCore(for: bookmark, setup: nil) { (core, error) in
						if core != nil {
							internetReachable = core!.connectionStatusSignals.contains(.reachable)
							OnMainThread {
								core?.retrieveItem(forPrivateLink: privateLinkURL, completionHandler: { (error, item) in
									if foundItem == nil {
										foundItem = item
									}
									if components?.host == bookmark.url?.host {
										matchedBookmark = bookmark
									}
									lastError = error
									OCCoreManager.shared.returnCore(for: bookmark, completionHandler: nil)
									group.leave()
								})
							}
						} else {
							group.leave()
						}
					}
				}
			}
		}

		group.notify(queue: DispatchQueue.main) {
			completion(foundItem, matchedBookmark, lastError, internetReachable)
		}

		return true
	}

	func resolveAndPresent(in window:UIWindow) {

		let hud : ProgressHUDViewController? = ProgressHUDViewController(on: nil)
		hud?.present(on: window.rootViewController?.topMostViewController, label: "Resolving link…".localized)

		self.retrieveLinkedItem(with: { (item, bookmark, _, internetReachable) in

			let completion = {
				if item == nil {
					let isOffline = internetReachable == false
					let accountFound = bookmark != nil
					let alertController = ThemedAlertController.alertControllerForUnresolvedLink(offline: isOffline, accountFound: accountFound)
					window.rootViewController?.topMostViewController.present(alertController, animated: true)

				} else {
					if let itemID = item?.localID, let bookmark = bookmark {
						window.display(itemWithID: itemID, in: bookmark)
					}
				}
			}

			if hud != nil {
				hud?.dismiss(completion: completion)
			} else {
				completion()
			}
		})
	}
}
