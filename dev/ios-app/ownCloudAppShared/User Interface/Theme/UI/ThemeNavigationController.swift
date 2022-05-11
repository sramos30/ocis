//
//  ThemeNavigationViewController.swift
//  ownCloud
//
//  Created by Felix Schwarz on 11.04.18.
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

public protocol CustomStatusBarViewControllerProtocol : class {
	func statusBarStyle() -> UIStatusBarStyle
}

open class ThemeNavigationController: UINavigationController {
	private var themeToken : ThemeApplierToken?

	override open var preferredStatusBarStyle : UIStatusBarStyle {
		if let object = self.viewControllers.last {
			if self.presentedViewController == nil, let loginViewController = object as? CustomStatusBarViewControllerProtocol {
				return loginViewController.statusBarStyle()
			} else {
				return Theme.shared.activeCollection.statusBarStyle
			}
		}

		return Theme.shared.activeCollection.statusBarStyle
	}

	open override var childForStatusBarStyle: UIViewController? {
		return nil
	}

	override open func viewDidLoad() {
		super.viewDidLoad()

		themeToken = Theme.shared.add(applier: {[weak self] (_, themeCollection, event) in
			self?.applyThemeCollection(themeCollection)
			self?.toolbar.applyThemeCollection(themeCollection)
			self?.view.backgroundColor = .clear

			if event == .update {
				self?.setNeedsStatusBarAppearanceUpdate()
			}
		}, applyImmediately: true)
	}

	deinit {
		Theme.shared.remove(applierForToken: themeToken)
	}

	open var popLastHandler : ((UIViewController?) -> Bool)?

	open override func popViewController(animated: Bool) -> UIViewController? {
		if let popLastHandler = popLastHandler {
			let viewControllerToPop = self.viewControllers.count > 1 ? self.viewControllers[self.viewControllers.count-2] : self.viewControllers.last

			if popLastHandler(viewControllerToPop) {
				return super.popViewController(animated: animated)
			} else {
				// Avoid empty navigation bar bug when returning nil
				self.pushViewController(UIViewController(), animated: false)
				return super.popViewController(animated: false)
			}
		}

		return super.popViewController(animated: animated)
	}
}
