//
//  SortBar.swift
//  ownCloud
//
//  Created by Pablo Carrascal on 31/05/2018.
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

public class SegmentedControl: UISegmentedControl {
	var oldValue : Int!

	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent? ) {
		self.oldValue = self.selectedSegmentIndex
		super.touchesBegan(touches, with: event)
	}

	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent? ) {
		super.touchesEnded(touches, with: event )

		if self.oldValue == self.selectedSegmentIndex {
			sendActions(for: UIControl.Event.valueChanged)
		}
	}
}

public enum SearchScope : Int, CaseIterable {
	case global
	case local

	var label : String {
		var name : String!

		switch self {
			case .global: name = "Account".localized
			case .local: name = "Folder".localized
		}

		return name
	}
}

public protocol SortBarDelegate: class {

	var sortDirection: SortDirection { get set }
	var sortMethod: SortMethod { get set }
	var searchScope: SearchScope { get set }

	func sortBar(_ sortBar: SortBar, didUpdateSortMethod: SortMethod)

	func sortBar(_ sortBar: SortBar, didUpdateSearchScope: SearchScope)

	func sortBar(_ sortBar: SortBar, presentViewController: UIViewController, animated: Bool, completionHandler: (() -> Void)?)

	func toggleSelectMode()
}

public class SortBar: UIView, Themeable, UIPopoverPresentationControllerDelegate {

	weak public var delegate: SortBarDelegate? {
		didSet {
			updateSortButtonTitle()
		}
	}

	// MARK: - Constants
	let sideButtonsSize: CGSize = CGSize(width: 44.0, height: 44.0)
	let leftPadding: CGFloat = 20.0
	let rightPadding: CGFloat = 20.0
	let rightSelectButtonPadding: CGFloat = 8.0
	let rightSearchScopePadding: CGFloat = 15.0
	let topPadding: CGFloat = 10.0
	let bottomPadding: CGFloat = 10.0

	// MARK: - Instance variables.

	public var sortSegmentedControl: SegmentedControl?
	public var sortButton: UIButton?
	public var searchScopeSegmentedControl : SegmentedControl?
	public var selectButton: UIButton?
	public var allowMultiSelect: Bool = true {
		didSet {
			updateSelectButtonVisibility()
		}
	}
	public var showSelectButton: Bool = false {
		didSet {
			updateSelectButtonVisibility()
		}
	}

	private func updateSelectButtonVisibility() {
		let showButton = showSelectButton && allowMultiSelect

		selectButton?.isHidden = !showButton
		selectButton?.accessibilityElementsHidden = !showButton
		selectButton?.isEnabled = showButton

		UIAccessibility.post(notification: .layoutChanged, argument: nil)
	}

	var showSearchScope: Bool = false {
		didSet {
			showSelectButton = !self.showSearchScope
			self.searchScopeSegmentedControl?.isHidden = false
			self.searchScopeSegmentedControl?.alpha = oldValue ? 1.0 : 0.0

			// Woraround for Accessibility: remove all elements, when element is hidden, otherwise the elements are still available for accessibility
			if oldValue == false {
				for scope in SearchScope.allCases {
					searchScopeSegmentedControl?.insertSegment(withTitle: scope.label, at: scope.rawValue, animated: false)
				}
				searchScopeSegmentedControl?.selectedSegmentIndex = searchScope.rawValue
			} else {
				self.searchScopeSegmentedControl?.removeAllSegments()
			}

			UIView.animate(withDuration: 0.3, animations: {
				self.searchScopeSegmentedControl?.alpha = self.showSearchScope ? 1.0 : 0.0
			}, completion: { (_) in
				self.searchScopeSegmentedControl?.isHidden = !self.showSearchScope
			})
		}
	}

	public var sortMethod: SortMethod {
		didSet {
			if self.superview != nil { // Only toggle direction if the view is already in the view hierarchy (i.e. not during initial setup)
				if oldValue == sortMethod {
					if delegate?.sortDirection == .ascendant {
						delegate?.sortDirection = .descendant
					} else {
						delegate?.sortDirection = .ascendant
					}
				} else {
					delegate?.sortDirection = .ascendant // Reset sort direction when switching sort methods
				}
			}
			updateSortButtonTitle()

			sortButton?.accessibilityLabel = NSString(format: "Sort by %@".localized as NSString, sortMethod.localizedName) as String
			sortButton?.sizeToFit()

			if let sortSegmentedControl = sortSegmentedControl, sortSegmentedControl.numberOfSegments > 0 {
				if let oldSementIndex = SortMethod.all.index(of: oldValue) {
					sortSegmentedControl.setTitle(oldValue.localizedName, forSegmentAt: oldSementIndex)
				}
				if let segmentIndex = SortMethod.all.index(of: sortMethod) {
					sortSegmentedControl.selectedSegmentIndex = segmentIndex
					sortSegmentedControl.setTitle(sortDirectionTitle(sortMethod.localizedName), forSegmentAt: segmentIndex)
				}
			}
			delegate?.sortBar(self, didUpdateSortMethod: sortMethod)
		}
	}

	public var searchScope : SearchScope {
		didSet {
			delegate?.searchScope = searchScope
			searchScopeSegmentedControl?.selectedSegmentIndex = searchScope.rawValue
		}
	}

	// MARK: - Init & Deinit

	public init(frame: CGRect, sortMethod: SortMethod, searchScope: SearchScope = .local) {
		sortSegmentedControl = SegmentedControl()
		selectButton = UIButton()
		sortButton = UIButton(type: .system)
		searchScopeSegmentedControl = SegmentedControl()

		self.sortMethod = sortMethod
		self.searchScope = searchScope

		super.init(frame: frame)

		if let sortButton = sortButton, let sortSegmentedControl = sortSegmentedControl, let searchScopeSegmentedControl = searchScopeSegmentedControl, let selectButton = selectButton {
			sortButton.translatesAutoresizingMaskIntoConstraints = false
			sortSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
			selectButton.translatesAutoresizingMaskIntoConstraints = false
			searchScopeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false

			sortButton.accessibilityIdentifier = "sort-bar.sortButton"
			sortSegmentedControl.accessibilityIdentifier = "sort-bar.segmentedControl"
			searchScopeSegmentedControl.accessibilityIdentifier = "sort-bar.searchScopeSegmentedControl"
			searchScopeSegmentedControl.accessibilityLabel = "Search scope".localized
			searchScopeSegmentedControl.isHidden = !self.showSearchScope
			searchScopeSegmentedControl.addTarget(self, action: #selector(searchScopeValueChanged), for: .valueChanged)

			self.addSubview(sortSegmentedControl)
			self.addSubview(sortButton)
			self.addSubview(searchScopeSegmentedControl)
			self.addSubview(selectButton)

			// Sort segmented control
			NSLayoutConstraint.activate([
				sortSegmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding),
				sortSegmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomPadding),
				sortSegmentedControl.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: leftPadding),

				searchScopeSegmentedControl.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -rightSearchScopePadding),
				searchScopeSegmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding),
				searchScopeSegmentedControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomPadding)
			])

			sortSegmentedControl.isHidden = true
			sortSegmentedControl.accessibilityElementsHidden = true
			sortSegmentedControl.isEnabled = false
			sortSegmentedControl.addTarget(self, action: #selector(sortSegmentedControllerValueChanged), for: .valueChanged)

			// Sort Button
			sortButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
			sortButton.titleLabel?.adjustsFontForContentSizeCategory = true
			sortButton.semanticContentAttribute = (sortButton.effectiveUserInterfaceLayoutDirection == .leftToRight) ? .forceRightToLeft : .forceLeftToRight

			sortButton.setImage(UIImage(named: "chevron-small-light"), for: .normal)

			sortButton.setContentHuggingPriority(.required, for: .horizontal)

			NSLayoutConstraint.activate([
				sortButton.topAnchor.constraint(equalTo: self.topAnchor, constant: topPadding),
				sortButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomPadding),
				sortButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftPadding),
				sortButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -rightPadding)
			])

			sortButton.isHidden = true
			sortButton.accessibilityElementsHidden = true
			sortButton.isEnabled = false
			sortButton.addTarget(self, action: #selector(presentSortButtonOptions), for: .touchUpInside)

			selectButton.setImage(UIImage(named: "select"), for: .normal)
			selectButton.tintColor = Theme.shared.activeCollection.favoriteEnabledColor
			selectButton.addTarget(self, action: #selector(toggleSelectMode), for: .touchUpInside)
			selectButton.accessibilityLabel = "Enter multiple selection".localized
			if #available(iOS 13.4, *) {
				selectButton.isPointerInteractionEnabled = true
			}

			NSLayoutConstraint.activate([
				selectButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
				selectButton.trailingAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -rightSelectButtonPadding),
				selectButton.heightAnchor.constraint(equalToConstant: sideButtonsSize.height),
				selectButton.widthAnchor.constraint(equalToConstant: sideButtonsSize.width)
			])
		}

		// Finalize view setup
		self.accessibilityIdentifier = "sort-bar"
		Theme.shared.register(client: self)

		selectButton?.isHidden = !showSelectButton
		updateForCurrentTraitCollection()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		Theme.shared.unregister(client: self)
	}

	// MARK: - Theme support

	public func applyThemeCollection(theme: Theme, collection: ThemeCollection, event: ThemeEvent) {
		self.sortButton?.applyThemeCollection(collection)
		self.selectButton?.applyThemeCollection(collection)
		self.sortSegmentedControl?.applyThemeCollection(collection)
		self.searchScopeSegmentedControl?.applyThemeCollection(collection)
		self.backgroundColor = collection.navigationBarColors.backgroundColor
	}

	// MARK: - Sort UI

	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		self.updateForCurrentTraitCollection()
	}

	public func updateForCurrentTraitCollection() {
		switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
		case (.compact, .regular):
			sortSegmentedControl?.removeAllSegments()
			sortSegmentedControl?.isHidden = true
			sortSegmentedControl?.accessibilityElementsHidden = true
			sortSegmentedControl?.isEnabled = false
			sortButton?.isHidden = false
			sortButton?.accessibilityElementsHidden = false
			sortButton?.isEnabled = true
		default:
			updateSortSegmentControl()
			sortSegmentedControl?.isHidden = false
			sortSegmentedControl?.accessibilityElementsHidden = false
			sortSegmentedControl?.isEnabled = true
			sortButton?.isHidden = true
			sortButton?.accessibilityElementsHidden = true
			sortButton?.isEnabled = false
		}

		UIAccessibility.post(notification: .layoutChanged, argument: nil)
	}

	// MARK: - Sort Direction Title

	func updateSortButtonTitle() {
		let title = NSString(format: "Sort by %@".localized as NSString, sortMethod.localizedName) as String
		sortButton?.setTitle(sortDirectionTitle(title), for: .normal)
	}

	func updateSortSegmentControl() {
		if let sortSegmentedControl = sortSegmentedControl {
			sortSegmentedControl.removeAllSegments()
			var longestTitleWidth : CGFloat = 0.0
			for method in SortMethod.all {
				sortSegmentedControl.insertSegment(withTitle: method.localizedName, at: SortMethod.all.index(of: method)!, animated: false)
				let titleWidth = method.localizedName.appending(" ↓").width(withConstrainedHeight: sortSegmentedControl.frame.size.height, font: UIFont.systemFont(ofSize: 16.0))
				if titleWidth > longestTitleWidth {
					longestTitleWidth = titleWidth
				}
				longestTitleWidth += 4 // add a padding to the longest title
			}

			var currentIndex = 0
			for _ in SortMethod.all {
				sortSegmentedControl.setWidth(longestTitleWidth, forSegmentAt: currentIndex)
				currentIndex += 1
			}
			if let segmentIndex = SortMethod.all.index(of: sortMethod) {
				sortSegmentedControl.selectedSegmentIndex = segmentIndex
				sortSegmentedControl.setTitle(sortDirectionTitle(sortMethod.localizedName), forSegmentAt: segmentIndex)
			}
		}
	}

	func sortDirectionTitle(_ title: String) -> String {
		if delegate?.sortDirection == .descendant {
			return String(format: "%@ ↓", title)
		} else {
			return String(format: "%@ ↑", title)
		}
	}

	// MARK: - Actions
	@objc private func presentSortButtonOptions(_ sender : UIButton) {
		let tableViewController = SortMethodTableViewController()
		tableViewController.modalPresentationStyle = .popover
		tableViewController.sortBarDelegate = self.delegate
		tableViewController.sortBar = self

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

		if self.effectiveUserInterfaceLayoutDirection == .rightToLeft {
			popoverPresentationController?.sourceRect = CGRect(x: 5, y: 0, width: 10, height: sender.frame.size.height)
		} else {
			popoverPresentationController?.sourceRect = CGRect(x: sender.frame.size.width - 12, y: 0, width: 10, height: sender.frame.size.height)
		}
		popoverPresentationController?.permittedArrowDirections = .up

		delegate?.sortBar(self, presentViewController: tableViewController, animated: true, completionHandler: nil)
	}

	@objc private func sortSegmentedControllerValueChanged() {
		if let selectedIndex = sortSegmentedControl?.selectedSegmentIndex {
			self.sortMethod = SortMethod.all[selectedIndex]
			delegate?.sortBar(self, didUpdateSortMethod: self.sortMethod)
		}
	}

	@objc private func searchScopeValueChanged() {
		if let selectedIndex = searchScopeSegmentedControl?.selectedSegmentIndex {
			self.searchScope = SearchScope(rawValue: selectedIndex)!
			delegate?.sortBar(self, didUpdateSearchScope: self.searchScope)
		}
	}

	@objc private func toggleSelectMode() {
		delegate?.toggleSelectMode()
	}

	// MARK: - UIPopoverPresentationControllerDelegate
	@objc open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}

	@objc open func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
		popoverPresentationController.backgroundColor = Theme.shared.activeCollection.tableBackgroundColor
	}
}
