//
//  CreateFolderAction.swift
//  ownCloud
//
//  Created by Pablo Carrascal on 20/11/2018.
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

import ownCloudSDK

open class CreateFolderAction : Action {
	override open class var identifier : OCExtensionIdentifier? { return OCExtensionIdentifier("com.owncloud.action.createFolder") }
	override open class var category : ActionCategory? { return .normal }
	override open class var name : String? { return "Create folder".localized }
	override open class var locations : [OCExtensionLocationIdentifier]? { return [.folderAction, .keyboardShortcut] }
	override open class var keyCommand : String? { return "N" }
	override open class var keyModifierFlags: UIKeyModifierFlags? { return [.command] }

	// MARK: - Extension matching
	override open class func applicablePosition(forContext: ActionContext) -> ActionPosition {
		if forContext.items.count > 1 {
			return .none
		}

		if forContext.items.first?.type != OCItemType.collection {
			return .none
		}

		if forContext.items.first?.permissions.contains(.createFolder) == false {
			return .none
		}

		return .first
	}

	// MARK: - Action implementation
	override open func run() {
		guard context.items.count > 0 else {
			completed(with: NSError(ocError: .itemNotFound))
			return
		}

		let item = context.items.first

		guard item != nil, let itemPath = item?.path else {
			completed(with: NSError(ocError: .itemNotFound))
			return
		}

		guard let viewController = context.viewController else {
			return
		}

		core?.suggestUnusedNameBased(on: "New Folder".localized, atPath: itemPath, isDirectory: true, using: .numbered, filteredBy: nil, resultHandler: { (suggestedName, _) in
			guard let suggestedName = suggestedName else { return }

			OnMainThread {
				let createFolderVC = NamingViewController( with: self.core, defaultName: suggestedName, stringValidator: { name in
					if name.contains("/") || name.contains("\\") {
						return (false, nil, "File name cannot contain / or \\".localized)
					} else {
						if let item = item {
							if ((try? self.core?.cachedItem(inParent: item, withName: name, isDirectory: true)) != nil) ||
							   ((try? self.core?.cachedItem(inParent: item, withName: name, isDirectory: false)) != nil) {
								return (false, "Item with same name already exists".localized, "An item with the same name already exists in this location.".localized)
							}
						}

						return (true, nil, nil)
					}
				}, completion: { newName, _ in
					guard newName != nil else {
						return
					}

					if let progress = self.core?.createFolder(newName!, inside: item!, options: nil, placeholderCompletionHandler: { (error, _) in
						if error != nil {
							Log.error("Error \(String(describing: error)) creating folder \(String(describing: newName))")
							self.completed(with: error)
						} else {
							self.completed()
						}
					}, resultHandler: nil) {
						self.publish(progress: progress)
					}
				})

				createFolderVC.navigationItem.title = "Create folder".localized

				let createFolderNavigationVC = ThemeNavigationController(rootViewController: createFolderVC)
				createFolderNavigationVC.modalPresentationStyle = .formSheet

				viewController.present(createFolderNavigationVC, animated: true)
			}
		})
	}

	override open class func iconForLocation(_ location: OCExtensionLocationIdentifier) -> UIImage? {
		if location == .toolbar || location == .folderAction || location == .contextMenuItem {
			return Theme.shared.image(for: "folder-create", size: CGSize(width: 30.0, height: 30.0))!.withRenderingMode(.alwaysTemplate)
		}

		return nil
	}
}
