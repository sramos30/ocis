//
//  ClientQueryViewController.swift
//  ownCloud
//
//  Created by Felix Schwarz on 05.04.18.
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

import UIKit
import ownCloudSDK
import ownCloudApp
import CoreServices

public typealias ClientActionVieDidAppearHandler = () -> Void
public typealias ClientActionCompletionHandler = (_ actionPerformed: Bool) -> Void

public struct OCItemDraggingValue {
	var item : OCItem
	var bookmarkUUID : String
}

open class ClientQueryViewController: QueryFileListTableViewController, UIDropInteractionDelegate, UIPopoverPresentationControllerDelegate {
	public var folderActionBarButton: UIBarButtonItem?
	public var plusBarButton: UIBarButtonItem?

	public var quotaLabel = UILabel()
	public var quotaObservation : NSKeyValueObservation?
	public var titleButtonThemeApplierToken : ThemeApplierToken?

	public var breadCrumbsPush : Bool = false

	weak public var clientRootViewController : UIViewController?

	private var _actionProgressHandler : ActionProgressHandler?
	public var revealItemLocalID : String?
	private var revealItemFound : Bool = false

	private let ItemDataUTI = "com.owncloud.ios-app.item-data"
	private let moreCellIdentifier = "moreCell"
	private let moreCellAccessibilityIdentifier = "more-results"

	open override var activeQuery : OCQuery {
		if let customSearchQuery = customSearchQuery {
			return customSearchQuery
		} else {
			return query
		}
	}

 	var customSearchQuery : OCQuery? {
 		willSet {
 			if customSearchQuery != newValue, let customQuery = customSearchQuery {
 				core?.stop(customQuery)
 				customQuery.delegate = nil
 			}
 		}

 		didSet {
 			if customSearchQuery != nil, let customQuery = customSearchQuery {
 				customQuery.delegate = self
 				customQuery.sortComparator = sortMethod.comparator(direction: sortDirection)
 				core?.start(customQuery)
 			}
 		}
 	}

	public var hasSearchResults : Bool {
		return customSearchQuery?.queryResults?.count ?? 0 > 0
	}

	open override var searchScope: SearchScope {
 		set {
 			UserDefaults.standard.setValue(newValue.rawValue, forKey: "search-scope")
 		}

 		get {
 			let scope = SearchScope(rawValue: UserDefaults.standard.integer(forKey: "search-scope")) ?? SearchScope.local
 			return scope
 		}
 	}

	// MARK: - Init & Deinit
	public override convenience init(core inCore: OCCore, query inQuery: OCQuery) {
		self.init(core: inCore, query: inQuery, rootViewController: nil)
	}

	public init(core inCore: OCCore, query inQuery: OCQuery, reveal inItem: OCItem? = nil, rootViewController: UIViewController?) {
		clientRootViewController = rootViewController
		revealItemLocalID = inItem?.localID
		breadCrumbsPush = revealItemLocalID != nil

		super.init(core: inCore, query: inQuery)
		updateTitleView()

		let lastPathComponent = (query.queryPath as NSString?)!.lastPathComponent
		if lastPathComponent.isRootPath {
			quotaObservation = core?.observe(\OCCore.rootQuotaBytesUsed, options: [.initial], changeHandler: { [weak self, weak core] (_, _) in
				let quotaUsed = core?.rootQuotaBytesUsed?.int64Value ?? 0

				OnMainThread { [weak self, weak core] in
					var footerText: String?

					if quotaUsed > 0 {

						let byteCounterFormatter = ByteCountFormatter()
						byteCounterFormatter.allowsNonnumericFormatting = false

						let quotaUsedFormatted = byteCounterFormatter.string(fromByteCount: quotaUsed)

						// A rootQuotaBytesRemaining value of nil indicates that no quota has been set
						if core?.rootQuotaBytesRemaining != nil, let quotaTotal = core?.rootQuotaBytesTotal?.int64Value {
							let quotaTotalFormatted = byteCounterFormatter.string(fromByteCount: quotaTotal )
							footerText = String(format: "%@ of %@ used".localized, quotaUsedFormatted, quotaTotalFormatted)
						} else {
							footerText = String(format: "Total: %@".localized, quotaUsedFormatted)
						}

						if let self = self {
							if self.items.count == 1 {
								footerText = String(format: "%@ item | ".localized, "\(self.items.count)") + (footerText ?? "")
							} else if self.items.count > 1 {
								footerText = String(format: "%@ items | ".localized, "\(self.items.count)") + (footerText ?? "")
							}
						}
					}

					self?.updateFooter(text: footerText)
				}
			})
		}
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		customSearchQuery = nil

		queryStateObservation = nil
		quotaObservation = nil

		if titleButtonThemeApplierToken != nil {
			Theme.shared.remove(applierForToken: titleButtonThemeApplierToken)
			titleButtonThemeApplierToken = nil
		}
	}

	open override func registerCellClasses() {
		super.registerCellClasses()

		self.tableView.register(ThemeTableViewCell.self, forCellReuseIdentifier: moreCellIdentifier)
	}

	// MARK: - Search events
	open override func willPresentSearchController(_ searchController: UISearchController) {
 		self.sortBar?.showSearchScope = true
		self.tableView.setContentOffset(.zero, animated: false)
 	}

	open override func willDismissSearchController(_ searchController: UISearchController) {
 		self.sortBar?.showSearchScope = false
 	}

	// MARK: - Search scope support
 	private var searchText: String?
 	private let maxResultCountDefault = 100 // Maximum number of results to return from database (default)
 	private var maxResultCount = 100 // Maximum number of results to return from database (flexible)

	open override func applySearchFilter(for searchText: String?, to query: OCQuery) {
 		self.searchText = searchText

 		updateCustomSearchQuery()
 	}

	open override func sortBar(_ sortBar: SortBar, didUpdateSearchScope: SearchScope) {
 		updateCustomSearchQuery()
 	}

	open override func sortBar(_ sortBar: SortBar, didUpdateSortMethod: SortMethod) {
 		sortMethod = didUpdateSortMethod

 		let comparator = sortMethod.comparator(direction: sortDirection)

 		query.sortComparator = comparator
 		customSearchQuery?.sortComparator = comparator

		if (customSearchQuery?.queryResults?.count ?? 0) >= maxResultCount {
	 		updateCustomSearchQuery()
		}
 	}

	private var lastSearchText : String?
	private var scrollToTopWithNextRefresh : Bool = false

 	public func updateCustomSearchQuery() {
		if lastSearchText != searchText {
			// Reset max result count when search text changes
			maxResultCount = maxResultCountDefault
			lastSearchText = searchText

			// Scroll to top when search text changes
			scrollToTopWithNextRefresh = true
		}

 		if let searchText = searchText,
		   let searchScope = sortBar?.searchScope,
		   searchScope == .global,
 		   let condition = OCQueryCondition.fromSearchTerm(searchText) {
			if let sortPropertyName = sortBar?.sortMethod.sortPropertyName {
				condition.sortBy = sortPropertyName
				condition.sortAscending = (sortDirection != .ascendant)
			}

			condition.maxResultCount = NSNumber(value: maxResultCount)

			self.customSearchQuery = OCQuery(condition:condition, inputFilter: nil)
 		} else {
 			self.customSearchQuery = nil
 		}

 		super.applySearchFilter(for: searchText, to: query)

 		self.queryHasChangesAvailable(activeQuery)
 	}

	// MARK: - View controller events
	open override func viewDidLoad() {
		super.viewDidLoad()

		self.tableView.dragDelegate = self
		self.tableView.dropDelegate = self
		self.tableView.dragInteractionEnabled = true

		var rightInset : CGFloat = 2
		var leftInset : CGFloat = 0
		if self.view.effectiveUserInterfaceLayoutDirection == .rightToLeft {
			rightInset = 0
			leftInset = 2
		}

		folderActionBarButton = UIBarButtonItem(image: UIImage(named: "more-dots")?.withInset(UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)), style: .plain, target: self, action: #selector(moreBarButtonPressed))
		folderActionBarButton?.accessibilityIdentifier = "client.folder-action"
		folderActionBarButton?.accessibilityLabel = "Actions".localized
		plusBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusBarButtonPressed))
		plusBarButton?.accessibilityIdentifier = "client.file-add"

		self.navigationItem.rightBarButtonItems = [folderActionBarButton!, plusBarButton!]

		quotaLabel.textAlignment = .center
		quotaLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
		quotaLabel.numberOfLines = 0
	}

	private var viewControllerVisible : Bool = false

	open override func viewDidAppear(_ animated: Bool) {
 		super.viewDidAppear(animated)

 		searchController?.delegate = self
 	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if let multiSelectionSupport = self as? MultiSelectSupport {
			multiSelectionSupport.exitMultiselection()
		}
	}

	private func updateFooter(text:String?) {
		let labelText = text ?? ""

		// Resize quota label
		self.quotaLabel.text = labelText
		self.quotaLabel.sizeToFit()
		var frame = self.quotaLabel.frame
		// Width is ignored and set by the UITableView when assigning to tableFooterView property
		frame.size.height = floor(self.quotaLabel.frame.size.height * 2.0)
		quotaLabel.frame = frame
		self.tableView.tableFooterView = quotaLabel
	}

	// MARK: - Theme support
	open override func applyThemeCollection(theme: Theme, collection: ThemeCollection, event: ThemeEvent) {
		super.applyThemeCollection(theme: theme, collection: collection, event: event)

		self.quotaLabel.textColor = collection.tableRowColors.secondaryLabelColor
	}

	// MARK: - Table view datasource
	open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numberOfRows = super.tableView(tableView, numberOfRowsInSection: section)

		if customSearchQuery != nil, numberOfRows >= maxResultCount {
			numberOfRows += 1
		}

		return numberOfRows
	}

	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let numberOfRows = super.tableView(tableView, numberOfRowsInSection: 0)
		var cell : UITableViewCell?

		if indexPath.row < numberOfRows {
			cell = super.tableView(tableView, cellForRowAt: indexPath)

			if revealItemLocalID != nil, let itemCell = cell as? ClientItemCell, let itemLocalID = itemCell.item?.localID {
				itemCell.revealHighlight = (itemLocalID == revealItemLocalID)
			}
		} else {
			let moreCell = tableView.dequeueReusableCell(withIdentifier: moreCellIdentifier, for: indexPath) as? ThemeTableViewCell

			moreCell?.accessibilityIdentifier = moreCellAccessibilityIdentifier
			moreCell?.textLabel?.text = "Show more results".localized

			cell = moreCell
		}

		return cell!
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath), cell.accessibilityIdentifier == moreCellAccessibilityIdentifier {
			maxResultCount += maxResultCountDefault
			updateCustomSearchQuery()
		} else {
			super.tableView(tableView, didSelectRowAt: indexPath)
		}
	}

	public override func showReveal(at path: IndexPath) -> Bool {
		return (customSearchQuery != nil)
	}

	// MARK: - Table view delegate

	open override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	open func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
		for item in session.items {
			if item.localObject == nil, item.itemProvider.hasItemConformingToTypeIdentifier("public.folder") {
				return false
			} else if let itemValues = item.localObject as? OCItemDraggingValue, let core = self.core, core.bookmark.uuid.uuidString != itemValues.bookmarkUUID, itemValues.item.type == .collection {
				return false
			}
		}
		return true
	}

	open func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

		if session.localDragSession != nil {
			if let indexPath = destinationIndexPath, items.count - 1 < indexPath.row {
				return UITableViewDropProposal(operation: .forbidden)
			}

			if let indexPath = destinationIndexPath, items[indexPath.row].type == .file {
				return UITableViewDropProposal(operation: .move)
			} else {
				return UITableViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
			}
		} else {
			return UITableViewDropProposal(operation: .copy)
		}
	}

	open func updateToolbarItemsForDropping(_ draggingValues: [OCItemDraggingValue]) {
		guard let tabBarController = self.tabBarController as? ToolAndTabBarToggling else { return }
		guard let toolbarItems = tabBarController.toolbar?.items else { return }

		if let core = self.core {
			let items = draggingValues.map({(value: OCItemDraggingValue) -> OCItem in
				return value.item
			})
			// Remove duplicates
			let uniqueItems = Array(Set(items))
			// Get possible associated actions
			let actionsLocation = OCExtensionLocation(ofType: .action, identifier: .toolbar)
			let actionContext = ActionContext(viewController: self, core: core, query: query, items: uniqueItems, location: actionsLocation)
			self.actions = Action.sortedApplicableActions(for: actionContext)

			// Enable / disable tool-bar items depending on action availability
			for item in toolbarItems {
				if self.actions?.contains(where: {type(of:$0).identifier == item.actionIdentifier}) ?? false {
					item.isEnabled = true
				} else {
					item.isEnabled = false
				}
			}
		}
	}

	// MARK: - UIBarButtonItem Drop Delegate
	open func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
		if customSearchQuery != nil {
			// No dropping on a smart search toolbar
			return false
		}
		return true
	}

	open func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
		return UIDropProposal(operation: .copy)
	}

	open func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
		guard let button = interaction.view as? UIButton, let identifier = button.actionIdentifier  else { return }

		if let action = self.actions?.first(where: {type(of:$0).identifier == identifier}) {
			// Configure progress handler
			action.progressHandler = makeActionProgressHandler()

			action.completionHandler = { (_, _) in
			}

			// Execute the action
			action.perform()
		}
	}

	open func dragInteraction(_ interaction: UIDragInteraction,
							  session: UIDragSession,
							  didEndWith operation: UIDropOperation) {
		removeToolbar()
	}

	// MARK: - Upload
	open func upload(itemURL: URL, name: String, completionHandler: ClientActionCompletionHandler? = nil) {
		if let rootItem = query.rootItem,
		   let progress = core?.importItemNamed(name, at: rootItem, from: itemURL, isSecurityScoped: false, options: nil, placeholderCompletionHandler: nil, resultHandler: { (error, _ core, _ item, _) in
			if error != nil {
				Log.debug("Error uploading \(Log.mask(name)) file to \(Log.mask(rootItem.path))")
				completionHandler?(false)
			} else {
				Log.debug("Success uploading \(Log.mask(name)) file to \(Log.mask(rootItem.path))")
				completionHandler?(true)
			}
		   }) {
			self.progressSummarizer?.startTracking(progress: progress)
		}
	}

	// MARK: - Navigation Bar Actions

	@objc open func plusBarButtonPressed(_ sender: UIBarButtonItem) {
		let controller = ThemedAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Actions for folderAction
		if let core = self.core, let rootItem = query.rootItem {
			let actionsLocation = OCExtensionLocation(ofType: .action, identifier: .folderAction)
			let actionContext = ActionContext(viewController: self, core: core, items: [rootItem], location: actionsLocation, sender: sender)

			let actions = Action.sortedApplicableActions(for: actionContext)

			if actions.count == 0 {
				// Handle case of no actions
				let alert = ThemedAlertController(title: "No actions available".localized, message: "No actions are available for this folder, possibly because of missing permissions.".localized, preferredStyle: .alert)

				alert.addAction(UIAlertAction(title: "OK".localized, style: .default))

				self.present(alert, animated: true)

				return
			}

			for action in actions {
				action.progressHandler = makeActionProgressHandler()

				if let controllerAction = action.provideAlertAction() {
					controller.addAction(controllerAction)
				}
			}
		}

		// Cancel button
		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
		controller.addAction(cancelAction)

		if let popoverController = controller.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		self.present(controller, animated: true)
	}

	@objc open func moreBarButtonPressed(_ sender: UIBarButtonItem) {
		guard let core = core, let rootItem = self.query.rootItem else {
			return
		}

		if let moreItemHandling = self as? MoreItemHandling {
			moreItemHandling.moreOptions(for: rootItem, at: .moreFolder, core: core, query: query, sender: sender)
		}
	}

	// MARK: - Path Bread Crumb Action
	@objc open func showPathBreadCrumb(_ sender: UIButton) {
		let tableViewController = BreadCrumbTableViewController()
		tableViewController.modalPresentationStyle = UIModalPresentationStyle.popover
		tableViewController.parentNavigationController = self.navigationController
		tableViewController.queryPath = (query.queryPath as NSString?)!
		if let shortName = core?.bookmark.shortName {
			tableViewController.bookmarkShortName = shortName
		}
		if breadCrumbsPush {
			tableViewController.navigationHandler = { [weak self] (path) in
				if let self = self, let core = self.core {
					let queryViewController = ClientQueryViewController(core: core, query: OCQuery(forPath: path))
					queryViewController.breadCrumbsPush = true

					self.navigationController?.pushViewController(queryViewController, animated: true)
				}
			}
		}

		if #available(iOS 13, *) {
			// On iOS 13.0/13.1, the table view's content needs to be inset by the height of the arrow
			// (this can hopefully be removed again in the future, if/when Apple addresses the issue)
			let popoverArrowHeight : CGFloat = 13

			tableViewController.tableView.contentInsetAdjustmentBehavior = .never
			tableViewController.tableView.contentInset = UIEdgeInsets(top: popoverArrowHeight, left: 0, bottom: 0, right: 0)
			tableViewController.tableView.separatorInset = UIEdgeInsets()
		}

		let popoverPresentationController = tableViewController.popoverPresentationController
		popoverPresentationController?.sourceView = sender
		popoverPresentationController?.delegate = self
		popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: sender.frame.size.width, height: sender.frame.size.height)

		present(tableViewController, animated: true, completion: nil)
	}

	// MARK: - ClientItemCell item resolution
	open override func item(for cell: ClientItemCell) -> OCItem? {
		guard let indexPath = self.tableView.indexPath(for: cell) else {
			return nil
		}

		return self.itemAt(indexPath: indexPath)
	}

	// MARK: - Updates
	open override func performUpdatesWithQueryChanges(query: OCQuery, changeSet: OCQueryChangeSet?) {
		guard query == activeQuery else {
			return
		}

		super.performUpdatesWithQueryChanges(query: query, changeSet: changeSet)

		if let revealItemLocalID = revealItemLocalID, !revealItemFound {
			var rowIdx : Int = 0

			for item in items {
				if item.localID == revealItemLocalID {
					OnMainThread {
						self.tableView.scrollToRow(at: IndexPath(row: rowIdx, section: 0), at: .middle, animated: true)
					}
					revealItemFound = true
					break
				}
				rowIdx += 1
			}
		}

		if let rootItem = self.query.rootItem, searchText == nil {
			if query.queryPath != "/" {
				var totalSize = String(format: "Total: %@".localized, rootItem.sizeLocalized)
				if self.items.count == 1 {
					totalSize = String(format: "%@ item | ".localized, "\(self.items.count)") + totalSize
				} else if self.items.count > 1 {
					totalSize = String(format: "%@ items | ".localized, "\(self.items.count)") + totalSize
				}
				self.updateFooter(text: totalSize)
			}

			if #available(iOS 13.0, *) {
				if  let bookmarkContainer = self.tabBarController as? BookmarkContainer {
					// Use parent folder for UI state restoration
					let activity = OpenItemUserActivity(detailItem: rootItem, detailBookmark: bookmarkContainer.bookmark)
					view.window?.windowScene?.userActivity = activity.openItemUserActivity
				}
			}
		} else {
			self.updateFooter(text: nil)
		}
	}

	open override func delegatedTableViewDataReload() {
		super.delegatedTableViewDataReload()

		if scrollToTopWithNextRefresh {
			scrollToTopWithNextRefresh = false

			OnMainThread {
				self.tableView.setContentOffset(.zero, animated: false)
			}
		}
	}

	// MARK: - Reloads
	open override func restoreSelectionAfterTableReload() {
		// Restore previously selected items
		guard tableView.isEditing else { return }

		guard selectedItemIds.count > 0 else { return }

		for row in 0..<self.items.count {
			if let itemLocalID = self.items[row].localID as OCLocalID? {
				if selectedItemIds.contains(itemLocalID) {
					self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
				}
			}
		}
	}

	// MARK: - UIPopoverPresentationControllerDelegate
	@objc open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

	@objc open func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
		popoverPresentationController.backgroundColor = Theme.shared.activeCollection.tableBackgroundColor
	}
}

// MARK: - Drag & Drop delegates
extension ClientQueryViewController: UITableViewDropDelegate {
	public func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
		guard let core = self.core else { return }

		for item in coordinator.items {
			if item.dragItem.localObject != nil {

				var destinationItem: OCItem

				guard let itemValues = item.dragItem.localObject as? OCItemDraggingValue, let itemName = itemValues.item.name, let sourceBookmark = OCBookmarkManager.shared.bookmark(forUUIDString: itemValues.bookmarkUUID) else {
					return
				}
				let item = itemValues.item

				if coordinator.proposal.intent == .insertIntoDestinationIndexPath {

					guard let destinationIndexPath = coordinator.destinationIndexPath else {
						return
					}

					guard items.count >= destinationIndexPath.row else {
						return
					}

					let rootItem = items[destinationIndexPath.row]

					guard rootItem.type == .collection else {
						return
					}

					destinationItem = rootItem

				} else {

					guard let rootItem = self.query.rootItem, item.parentFileID != rootItem.fileID else {
						return
					}

					destinationItem =  rootItem
				}

				// Move Items in the same Account
				if core.bookmark.uuid.uuidString == itemValues.bookmarkUUID {
					if let progress = core.move(item, to: destinationItem, withName: itemName, options: nil, resultHandler: { (error, _, _, _) in
						if error != nil {
							Log.log("Error \(String(describing: error)) moving \(String(describing: item.path))")
						}
					}) {
						self.progressSummarizer?.startTracking(progress: progress)
					}
					// Copy Items between Accounts
				} else {
					OCCoreManager.shared.requestCore(for: sourceBookmark, setup: nil) { (srcCore, error) in
						if error == nil {
							srcCore?.downloadItem(item, options: nil, resultHandler: { (error, _, srcItem, _) in
								if error == nil, let srcItem = srcItem, let localURL = srcCore?.localCopy(of: srcItem) {
									core.importItemNamed(srcItem.name, at: destinationItem, from: localURL, isSecurityScoped: false, options: nil, placeholderCompletionHandler: nil) { (_, _, _, _) in
									}
								}
							})
						}
					}
				}
			} else {
				// Import Items from outside
				let typeIdentifiers = item.dragItem.itemProvider.registeredTypeIdentifiers
				let preferredUTIs = [
					kUTTypeImage,
					kUTTypeMovie,
					kUTTypePDF,
					kUTTypeText,
					kUTTypeRTF,
					kUTTypeHTML,
					kUTTypePlainText
				]
				var useUTI : String?
				var useIndex : Int = Int.max

				for typeIdentifier in typeIdentifiers {
					if typeIdentifier != ItemDataUTI, !typeIdentifier.hasPrefix("dyn.") {
						for preferredUTI in preferredUTIs {
							let conforms = UTTypeConformsTo(typeIdentifier as CFString, preferredUTI)

							// Log.log("\(preferredUTI) vs \(typeIdentifier) -> \(conforms)")

							if conforms {
								if let utiIndex = preferredUTIs.index(of: preferredUTI), utiIndex < useIndex {
									useUTI = typeIdentifier
									useIndex = utiIndex
								}
							}
						}
					}
				}

				if useUTI == nil, typeIdentifiers.count == 1 {
					useUTI = typeIdentifiers.first
				}

				if useUTI == nil {
					useUTI = kUTTypeData as String
				}

				var fileName: String?

				item.dragItem.itemProvider.loadFileRepresentation(forTypeIdentifier: useUTI!) { (url, _ error) in
					guard let url = url else { return }

					let fileNameMaxLength = 16

					if useUTI == kUTTypeUTF8PlainText as String {
						fileName = try? String(String(contentsOf: url, encoding: .utf8).prefix(fileNameMaxLength) + ".txt")
					}

					if useUTI == kUTTypeRTF as String {
						let options = [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtf]
						fileName = try? String(NSAttributedString(url: url, options: options, documentAttributes: nil).string.prefix(fileNameMaxLength) + ".rtf")
					}

					fileName = fileName?
						.trimmingCharacters(in: .illegalCharacters)
						.trimmingCharacters(in: .whitespaces)
						.trimmingCharacters(in: .newlines)
						.filter({ $0.isASCII })

					if fileName == nil {
						fileName = url.lastPathComponent
					}

					guard let name = fileName else { return }

					self.upload(itemURL: url, name: name)
				}
			}
		}
	}
}

extension ClientQueryViewController: UITableViewDragDelegate {
	public func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

		if DisplaySettings.shared.preventDraggingFiles {
			return [UIDragItem]()
		}

		if !self.tableView.isEditing {
			if let multiSelectSupport = self as? MultiSelectSupport {
				multiSelectSupport.populateToolbar()
			}
		}

		var selectedItems = [OCItemDraggingValue]()
		// Add Items from Multiselection too
		if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
			if selectedIndexPaths.count > 0 {
				for indexPath in selectedIndexPaths {
					if let selectedItem : OCItem = itemAt(indexPath: indexPath), let uuid = core?.bookmark.uuid.uuidString {
						let draggingValue = OCItemDraggingValue(item: selectedItem, bookmarkUUID: uuid)
						selectedItems.append(draggingValue)
					}
				}
			}
		}
		for dragItem in session.items {
			guard let item = dragItem.localObject as? OCItem, let uuid = core?.bookmark.uuid.uuidString else { continue }
			let draggingValue = OCItemDraggingValue(item: item, bookmarkUUID: uuid)
			selectedItems.append(draggingValue)
		}

		if let item: OCItem = itemAt(indexPath: indexPath), let uuid = core?.bookmark.uuid.uuidString {
			let draggingValue = OCItemDraggingValue(item: item, bookmarkUUID: uuid)
			selectedItems.append(draggingValue)

			updateToolbarItemsForDropping(selectedItems)

			guard let dragItem = itemForDragging(draggingValue: draggingValue) else { return [] }
			return [dragItem]
		}

		return []
	}

	public func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
		var selectedItems = [OCItemDraggingValue]()
		for dragItem in session.items {
			guard let item = dragItem.localObject as? OCItem, let uuid = core?.bookmark.uuid.uuidString else { continue }
			let draggingValue = OCItemDraggingValue(item: item, bookmarkUUID: uuid)
			selectedItems.append(draggingValue)
		}

		if let item: OCItem = itemAt(indexPath: indexPath), let uuid = core?.bookmark.uuid.uuidString {
			let draggingValue = OCItemDraggingValue(item: item, bookmarkUUID: uuid)
			selectedItems.append(draggingValue)

			updateToolbarItemsForDropping(selectedItems)

			guard let dragItem = itemForDragging(draggingValue: draggingValue) else { return [] }
			return [dragItem]
		}

		return []
	}

	public func tableView(_: UITableView, dragSessionDidEnd: UIDragSession) {
		if !self.tableView.isEditing {
			removeToolbar()
		}
	}

	public func itemForDragging(draggingValue : OCItemDraggingValue) -> UIDragItem? {
		let item = draggingValue.item

		guard let core = self.core else {
			return nil
		}

		switch item.type {
		case .collection:
			guard let data = item.serializedData() else { return nil }

			let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: ItemDataUTI)
			let dragItem = UIDragItem(itemProvider: itemProvider)

			dragItem.localObject = draggingValue

			return dragItem

		case .file:
			guard let itemMimeType = item.mimeType else { return nil }

			let mimeTypeCF = itemMimeType as CFString
			guard let rawUti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeTypeCF, nil)?.takeRetainedValue() as String? else { return nil }

			let itemProvider = NSItemProvider()

			itemProvider.suggestedName = item.name

			itemProvider.registerFileRepresentation(forTypeIdentifier: rawUti, fileOptions: [], visibility: .all, loadHandler: { [weak core] (completionHandler) -> Progress? in
				var progress : Progress?

				guard let core = core else {
					completionHandler(nil, false, NSError(domain: OCErrorDomain, code: Int(OCError.internal.rawValue), userInfo: nil))
					return nil
				}

				if let localFileURL = core.localCopy(of: item) {
					// Provide local copies directly
					completionHandler(localFileURL, true, nil)
				} else {
					// Otherwise download the file and provide it when done
					progress = core.downloadItem(item, options: [
						.returnImmediatelyIfOfflineOrUnavailable : true,
						.addTemporaryClaimForPurpose : OCCoreClaimPurpose.view.rawValue
					], resultHandler: { [weak self] (error, core, item, file) in
						guard error == nil, let fileURL = file?.url else {
							completionHandler(nil, false, error)
							return
						}

						completionHandler(fileURL, true, nil)

						if let claim = file?.claim, let item = item, let self = self {
							self.core?.remove(claim, on: item, afterDeallocationOf: [fileURL])
						}
					})
				}

				return progress
			})

			itemProvider.registerDataRepresentation(forTypeIdentifier: ItemDataUTI, visibility: .ownProcess) { (completionHandler) -> Progress? in
				guard let data = item.serializedData() else { return nil }
				completionHandler(data, nil)

				return nil
			}

			let dragItem = UIDragItem(itemProvider: itemProvider)
			dragItem.localObject = draggingValue

			return dragItem
		}
	}
}

extension ClientQueryViewController {

	@objc public func exitedMultiselection() {
		updateTitleView()
	}

	open func updateTitleView() {
		let lastPathComponent = (query.queryPath as NSString?)!.lastPathComponent

		if lastPathComponent.isRootPath, let shortName = core?.bookmark.shortName {
			self.navigationItem.title = shortName
		} else {
			if #available(iOS 14.0, *) {
				self.navigationItem.backButtonDisplayMode = .generic
				let lastPathComponent = (query.queryPath as NSString?)!.lastPathComponent
				self.title = lastPathComponent
			}

			let titleButton = UIButton()
			titleButton.setTitle(lastPathComponent, for: .normal)
			titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
			titleButton.addTarget(self, action: #selector(showPathBreadCrumb(_:)), for: .touchUpInside)
			titleButton.sizeToFit()
			titleButton.accessibilityLabel = "Show parent paths".localized
			titleButton.accessibilityIdentifier = "show-paths-button"
			titleButton.semanticContentAttribute = (titleButton.effectiveUserInterfaceLayoutDirection == .leftToRight) ? .forceRightToLeft : .forceLeftToRight
			titleButton.setImage(UIImage(named: "chevron-small-light"), for: .normal)
			titleButtonThemeApplierToken = Theme.shared.add(applier: { (_, collection, _) in
				titleButton.setTitleColor(collection.navigationBarColors.labelColor, for: .normal)
				titleButton.tintColor = collection.navigationBarColors.labelColor
			})
			self.navigationItem.titleView = titleButton
		}
	}
}

// MARK: - UINavigationControllerDelegate
extension ClientQueryViewController: UINavigationControllerDelegate {}
