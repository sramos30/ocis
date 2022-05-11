//
//  StaticLoginViewController.swift
//  ownCloud
//
//  Created by Felix Schwarz on 26.11.18.
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
import ownCloudAppShared

class StaticLoginViewController: UIViewController, Themeable, StateRestorationConnectProtocol, CustomStatusBarViewControllerProtocol {

	private var bookmark: OCBookmark?
	private var lastVisibleItemId: String?

	private let maximumContentWidth : CGFloat = 400
	let loginBundle : StaticLoginBundle

	var backgroundImageView : UIImageView?

	var headerContainerView : UIView?
	var headerLogoView : UIImageView?

	var contentContainerView : UIView?

	var contentViewController : UIViewController? {
		willSet {
			contentViewController?.willMove(toParent: nil)
		}

		didSet {
			if contentContainerView != nil, contentViewController?.view != nil {
				contentContainerView?.addSubview(contentViewController!.view!)
				contentViewController!.view!.translatesAutoresizingMaskIntoConstraints = false

				NSLayoutConstraint.activate([
					contentViewController!.view!.topAnchor.constraint(equalTo: contentContainerView!.safeAreaLayoutGuide.topAnchor),
					contentViewController!.view!.bottomAnchor.constraint(equalTo: contentContainerView!.safeAreaLayoutGuide.bottomAnchor),
					contentViewController!.view!.leftAnchor.constraint(equalTo: contentContainerView!.safeAreaLayoutGuide.leftAnchor, constant: 20),
					contentViewController!.view!.rightAnchor.constraint(equalTo: contentContainerView!.safeAreaLayoutGuide.rightAnchor, constant: -20)
				])

				// Animate transition
				if oldValue != nil {
					contentViewController?.view.alpha = 0.0

					UIView.animate(withDuration: 0.25, animations: {
						if oldValue != self.contentViewController { // only animate the old view controller if it is distinct
							oldValue?.view?.alpha = 0.0
						}
						self.contentViewController?.view.alpha = 1.0
					}, completion: { (_) in
						if oldValue != self.contentViewController { // only animate the old view controller if it is distinct
							oldValue?.view?.removeFromSuperview()
							oldValue?.removeFromParent()
							oldValue?.view?.alpha = 1.0
						}

						self.contentViewController?.didMove(toParent: self)
					})
				} else {
					self.contentViewController?.didMove(toParent: self)
				}
			}
		}
	}

	var toolbarShown : Bool = false {
		didSet {
			if self.toolbarItems == nil, toolbarShown, OCBookmarkManager.shared.bookmarks.count == 0 {
				let settingsBarButtonItem = UIBarButtonItem(title: "Settings".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(settings))
				settingsBarButtonItem.accessibilityIdentifier = "settingsBarButtonItem"

				if VendorServices.shared.isBranded {
					self.toolbarItems = [
						UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
						settingsBarButtonItem
					]
				} else {
					let feedbackBarButtonItem = UIBarButtonItem(title: "Feedback".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(sendFeedback))
					feedbackBarButtonItem.accessibilityIdentifier = "helpBarButtonItem"

					self.toolbarItems = [
						feedbackBarButtonItem,
						UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil),
						settingsBarButtonItem
					]
				}
			}
			self.navigationController?.setToolbarHidden(!toolbarShown, animated: true)
		}
	}
	init(with staticLoginBundle: StaticLoginBundle) {
		loginBundle = staticLoginBundle

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func statusBarStyle() -> UIStatusBarStyle {
		return Theme.shared.activeCollection.loginStatusBarStyle
	}

	override func loadView() {
		let rootView = UIView()
		let headerVerticalSpacing : CGFloat = 40

		backgroundImageView = UIImageView()
		backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
		rootView.addSubview(backgroundImageView!)

		headerContainerView = UIView()
		headerContainerView?.translatesAutoresizingMaskIntoConstraints = false
		rootView.addSubview(headerContainerView!)

		contentContainerView = UIView()
		contentContainerView?.translatesAutoresizingMaskIntoConstraints = false
		rootView.addSubview(contentContainerView!)

		headerLogoView = UIImageView()
		headerLogoView?.translatesAutoresizingMaskIntoConstraints = false
		headerContainerView?.addSubview(headerLogoView!)

		NSLayoutConstraint.activate([
			// Background image view
			backgroundImageView!.topAnchor.constraint(equalTo: rootView.topAnchor),
			backgroundImageView!.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
			backgroundImageView!.leftAnchor.constraint(equalTo: rootView.leftAnchor),
			backgroundImageView!.rightAnchor.constraint(equalTo: rootView.rightAnchor),

			// Header
				// Logo size
				headerLogoView!.leftAnchor.constraint(equalTo: headerContainerView!.safeAreaLayoutGuide.leftAnchor),
				headerLogoView!.rightAnchor.constraint(equalTo: headerContainerView!.safeAreaLayoutGuide.rightAnchor),
				headerLogoView!.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.25, constant: 0),

				// Logo and label position
				headerLogoView!.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor, constant: headerVerticalSpacing),
				headerLogoView!.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
				headerLogoView!.bottomAnchor.constraint(equalTo: headerContainerView!.bottomAnchor, constant: 0),

				// Header position
				headerContainerView!.topAnchor.constraint(equalTo: rootView.topAnchor),
				headerContainerView!.leftAnchor.constraint(equalTo: rootView.leftAnchor),
				headerContainerView!.rightAnchor.constraint(equalTo: rootView.rightAnchor),

			// Content
				// Content container
				contentContainerView!.topAnchor.constraint(equalTo: headerContainerView!.bottomAnchor),
				contentContainerView!.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
		])

		if UIDevice.current.isIpad {
			NSLayoutConstraint.activate([
				contentContainerView!.leadingAnchor.constraint(equalTo: rootView.leadingAnchor).with(priority: .defaultLow),
				contentContainerView!.trailingAnchor.constraint(equalTo: rootView.trailingAnchor).with(priority: .defaultLow),
				contentContainerView!.widthAnchor.constraint(lessThanOrEqualToConstant: maximumContentWidth).with(priority: .defaultHigh),
				contentContainerView!.centerXAnchor.constraint(equalTo: rootView.centerXAnchor)
			])
		} else {
			NSLayoutConstraint.activate([
				contentContainerView!.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
				contentContainerView!.trailingAnchor.constraint(equalTo: rootView.trailingAnchor)
			])
		}

		self.view = rootView

		Theme.shared.register(client: self, applyImmediately: true)
	}

	func applyThemeCollection(theme: Theme, collection: ThemeCollection, event: ThemeEvent) {
//		self.view.backgroundColor = collection.tableBackgroundColor
//		self.headerView?.backgroundColor = collection.tableGroupBackgroundColor
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		OCItem.registerIcons()

		if let organizationLogoImage = loginBundle.organizationLogoImage {
			headerLogoView?.image = organizationLogoImage
			headerLogoView?.contentMode = .scaleAspectFit
		}

		if let organizationBackgroundImage = loginBundle.organizationBackgroundImage {
			backgroundImageView?.image = organizationBackgroundImage
			backgroundImageView?.contentMode = .scaleAspectFill
		}

		self.navigationController?.toolbar.isTranslucent = false
		self.toolbarShown = true
	}

	func connect(to bookmark: OCBookmark, lastVisibleItemId: String?, animated: Bool, present message: OCMessage? = nil) {
		self.bookmark = bookmark
		self.lastVisibleItemId = lastVisibleItemId
		self.openBookmark(bookmark)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if contentViewController == nil {
			if Migration.shared.legacyDataFound {
				let migrationViewController = MigrationViewController()
				let navigationController = ThemeNavigationController(rootViewController: migrationViewController)
				migrationViewController.migrationFinishedHandler = {
					Migration.shared.wipeLegacyData()
					self.showFirstScreen()
				}
				navigationController.modalPresentationStyle = .fullScreen
				self.present(navigationController, animated: false)
			} else {
				showFirstScreen()
			}
		}

		if AppLockManager.shared.passcode == nil && AppLockSettings.shared.isPasscodeEnforced {
			PasscodeSetupCoordinator(parentViewController: self, action: .setup).start()
		} else if let passcode = AppLockManager.shared.passcode, passcode.count < AppLockSettings.shared.requiredPasscodeDigits {
			PasscodeSetupCoordinator(parentViewController: self, action: .upgrade).start()
		}
	}

	@objc func showFirstScreen() {
		var firstViewController : UIViewController?

		if OCBookmarkManager.shared.bookmarks.count > 0 {
			// Login selection view
			firstViewController = self.buildBookmarkSelector()
		} else if let firstProfile = loginBundle.profiles.first {
			// Setup flow
			self.toolbarShown = true
			if loginBundle.profiles.count > 1 {
				// Profile setup selector
				firstViewController = buildProfileSetupSelector(title: firstProfile.welcome!)
			} else {
				// Single Profile setup
				firstViewController = buildSetupViewController(for: firstProfile)
			}
		}

		if firstViewController != nil {
			let navigationViewController = ThemeNavigationController(rootViewController: firstViewController!)

			navigationViewController.isNavigationBarHidden = true

 			// Saved for future reference. Ended up not being used now because ServerListTableViewController gained the
 			// ability to start the PushTransition from a custom viewController (.pushFromViewController), at which point
 			// PushTransition correctly restores the view.
 			// --
 			// if let serverListTableViewController = firstViewController as? ServerListTableViewController {
 			// 	// This block is executed when the transition back from the server list table view controller has finished
 			// 	// - at which point it is removed due to an iOS bug documented in PushTransition. To re-attach the view
 			// 	// controller in the right place, this custom pushTransitionRecovery is used
 			// 	serverListTableViewController.pushTransitionRecovery = { (_, _) in
 			// 		self.contentViewController = navigationViewController
 			// 	}
 			// }

			self.contentViewController = navigationViewController
		}
	}

	// MARK: - View controller builders
	func buildProfileSetupSelector(title : String, includeCancelOption: Bool = false) -> StaticLoginStepViewController {
		let selectorViewController : StaticLoginStepViewController = StaticLoginStepViewController(loginViewController: self)
		let profileSection = StaticTableViewSection(headerTitle: "")

		profileSection.addStaticHeader(title: title, message: "Please pick a profile to begin setup".localized)

		for profile in loginBundle.profiles {
			profileSection.add(row: StaticTableViewRow(rowWithAction: { (row, _) in
				if let stepViewController = row.viewController as? StaticLoginStepViewController {
					if let setupViewController = stepViewController.loginViewController?.buildSetupViewController(for: profile) {
						stepViewController.navigationController?.pushViewController(setupViewController, animated: true)
					}
				}
			}, title: profile.name!, accessoryType: .disclosureIndicator, identifier: profile.identifier))
		}

		if includeCancelOption {
			let (_, cancelButton) = profileSection.addButtonFooter(cancelLabel: "Cancel".localized)

			cancelButton?.addTarget(selectorViewController, action: #selector(selectorViewController.popViewController), for: .touchUpInside)
		}

		selectorViewController.addSection(profileSection)

		return (selectorViewController)
	}

	func buildSetupViewController(for profile: StaticLoginProfile) -> StaticLoginSetupViewController {
		return StaticLoginSetupViewController(loginViewController: self, profile: profile)
	}

	func buildBookmarkSelector() -> UIViewController {
		var serverList : ServerListTableViewController?

		if OCBookmarkManager.shared.bookmarks.count > 1 {
		//if OCBookmarkManager.shared.bookmarks.count > 1 || VendorServices.shared.canAddAccount {
			if #available(iOS 13.0, *) {
				serverList = StaticLoginServerListViewController(style: .insetGrouped)
			} else {
				serverList = StaticLoginServerListViewController(style: .grouped)
			}
			(serverList as? StaticLoginServerListViewController)?.staticLoginViewController = self
		} else {
			if #available(iOS 13.0, *) {
				serverList = StaticLoginSingleAccountServerListViewController(style: .insetGrouped)
			} else {
				serverList = StaticLoginSingleAccountServerListViewController(style: .grouped)
			}
			(serverList as? StaticLoginSingleAccountServerListViewController)?.staticLoginViewController = self
		}

		serverList?.hasToolbar = false

		// Push ClientRootViewControllers via PushTransition from this view controller, so it is correctly
		// animated (otherwise just the list is moved *inside* this view controller, which is weird) and the
		// PushTransition correctly restores the view
		serverList?.pushFromViewController = self

		return serverList!
	}

	func profile(for staticLoginProfileIdentifier: StaticLoginProfileIdentifier) -> StaticLoginProfile? {
		return loginBundle.profiles.first(where: { (profile) -> Bool in
			return (profile.identifier == staticLoginProfileIdentifier)
		})
	}

	func switchToTheme(with styleIdentifier: ThemeStyleIdentifier) {
		if let themeStyle = ThemeStyle.forIdentifier(styleIdentifier) {
			Theme.shared.switchThemeCollection(ThemeCollection(with: themeStyle))
		}
	}

	// MARK: - Actions
	@objc func sendFeedback() {
		VendorServices.shared.sendFeedback(from: self)
	}

	@objc func settings() {
        	let viewController : SettingsViewController = SettingsViewController(style: .grouped)
        	let navigationViewController : ThemeNavigationController = ThemeNavigationController(rootViewController: viewController)

		self.present(navigationViewController, animated: true, completion: nil)
	}

	func openBookmark(_ bookmark: OCBookmark, closeHandler: (() -> Void)? = nil) {
		let clientRootViewController = ClientRootViewController(bookmark: bookmark)
		clientRootViewController.modalPresentationStyle = .overFullScreen

		clientRootViewController.afterCoreStart(self.lastVisibleItemId, completionHandler: { (error) in
			// Set up custom push transition for presentation
			if let navigationController = self.navigationController {
				if let error = error {
					let alert = UIAlertController(title: NSString(format: "Error opening %@".localized as NSString, bookmark.shortName) as String, message: error.localizedDescription, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))

					navigationController.present(alert, animated: true)
				} else {
					OCBookmarkManager.lastBookmarkSelectedForConnection = bookmark

					let transitionDelegate = PushTransitionDelegate()

					clientRootViewController.pushTransition = transitionDelegate // Keep a reference, so it's still around on dismissal
					clientRootViewController.transitioningDelegate = transitionDelegate
					clientRootViewController.modalPresentationStyle = .custom

					navigationController.present(clientRootViewController, animated: true)
				}
			}
			self.showFirstScreen()
		})
	}
}
