//
//  MoreSettingsSection.swift
//  ownCloud
//
//  Created by Pablo Carrascal on 03/05/2018.
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

import CoreFoundation
import UIKit
import WebKit
import MessageUI
import SafariServices
import ownCloudSDK
import ownCloudApp
import ownCloudAppShared

class MoreSettingsSection: SettingsSection {
	// MARK: - More Settings Cells

	private var documentationRow: StaticTableViewRow?
	private var helpRow: StaticTableViewRow?
	private var sendFeedbackRow: StaticTableViewRow?
	private var recommendRow: StaticTableViewRow?
	private var privacyPolicyRow: StaticTableViewRow?
	private var termsOfUseRow: StaticTableViewRow?
	private var acknowledgementsRow: StaticTableViewRow?
	private var appVersionRow: StaticTableViewRow?

	override init(userDefaults: UserDefaults) {
		super.init(userDefaults: userDefaults)
		self.headerTitle = "More".localized

		self.identifier = "settings-more-section"

		createRows()
		updateUI()
	}

	// MARK: - Creation of the rows.

	private func createRows() {

		documentationRow = StaticTableViewRow(rowWithAction: { [weak self] (_, _) in
			if let url = VendorServices.shared.documentationURL {
				self?.openSFWebViewWithConfirmation(for: url)
			}
		}, title: "Documentation".localized, accessoryType: .disclosureIndicator, identifier: "documentation")

		if let helpURL = VendorServices.shared.helpURL {
			helpRow = StaticTableViewRow(rowWithAction: { [weak self] (_, _) in
				self?.openSFWebViewWithConfirmation(for: helpURL)
			}, title: "Help".localized, accessoryType: .disclosureIndicator, identifier: "help")
		}

		sendFeedbackRow = StaticTableViewRow(rowWithAction: { [weak self] (_, _) in
			if let viewController = self?.viewController {
				VendorServices.shared.sendFeedback(from: viewController)
			}
		}, title: "Send feedback".localized, accessoryType: .disclosureIndicator, identifier: "send-feedback")

		recommendRow = StaticTableViewRow(rowWithAction: { [weak self] (_, _) in
			if let viewController = self?.viewController {
				VendorServices.shared.recommendToFriend(from: viewController)
			}
		}, title: "Recommend to a friend".localized, accessoryType: .disclosureIndicator, identifier: "recommend-friend")

		if let privacyURL = VendorServices.shared.privacyURL {
			privacyPolicyRow = StaticTableViewRow(rowWithAction: { [weak self] (_, _) in
				self?.openSFWebViewWithConfirmation(for: privacyURL)
			}, title: "Privacy Policy".localized, accessoryType: .disclosureIndicator, identifier: "privacy-policy")
		}

		if let termsOfUseURL = VendorServices.shared.termsOfUseURL {
			termsOfUseRow = StaticTableViewRow(rowWithAction: { [weak self] (_, _) in
				self?.openSFWebViewWithConfirmation(for: termsOfUseURL)
			}, title: "Terms Of Use".localized, accessoryType: .disclosureIndicator, identifier: "terms-of-use")
		}

		acknowledgementsRow = StaticTableViewRow(rowWithAction: { (row, _) in
			row.viewController?.navigationController?.pushViewController(AcknowledgementsTableViewController(style: .grouped), animated: true)
		}, title: "Acknowledgements".localized, accessoryType: .disclosureIndicator, identifier: "acknowledgements")

		var buildType = "release".localized
		if VendorServices.shared.isBetaBuild {
			buildType = "beta".localized
		}

		var appSuffix = ""
		if OCLicenseEMMProvider.isEMMVersion {
			appSuffix = "-EMM"
		}

		let localizedFooter = "%@%@ %@ version %@ build %@\n(app: %@, sdk: %@)".localized
		let footerTitle = String(format: localizedFooter, VendorServices.shared.appName, appSuffix, buildType, VendorServices.shared.appVersion, VendorServices.shared.appBuildNumber, VendorServices.shared.lastGitCommit, OCAppIdentity.shared.sdkCommit ?? "unknown".localized)

		appVersionRow = StaticTableViewRow(rowWithAction: { (_, _) in
			UIPasteboard.general.string = footerTitle
			guard let viewController = self.viewController else { return }
			_ = NotificationHUDViewController(on: viewController, title: "App Version".localized, subtitle: "Version information were copied to the clipboard".localized, completion: nil)
		}, title: "App Version".localized, subtitle: footerTitle, identifier: "app-version")
	}

	// MARK: - Update UI
	func updateUI() {
		var rows : [StaticTableViewRow] = []

		if VendorServices.shared.documentationURL != nil {
			rows.append(documentationRow!)
		}

		if VendorServices.shared.helpURL != nil {
			rows.append(helpRow!)
		}

		if VendorServices.shared.feedbackMail != nil || Branding.shared.feedbackURL != nil {
			rows.append(sendFeedbackRow!)
		}

		if let recommendToFriend = VendorServices.classSetting(forOCClassSettingsKey: .recommendToFriendEnabled) as? Bool, recommendToFriend {
			rows.append(recommendRow!)
		}

		if let privacyPolicyRow = privacyPolicyRow {
			rows.append(privacyPolicyRow)
		}
		if let termsOfUseRow = termsOfUseRow {
			rows.append(termsOfUseRow)
		}

		rows.append(contentsOf: [acknowledgementsRow!, appVersionRow!])

		add(rows: rows)
	}

	private func openSFWebViewWithConfirmation(for url: URL) {
		let alert = ThemedAlertController(title: "Do you want to open the following URL?".localized,
					      message: url.absoluteString,
					      preferredStyle: .alert)

		let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
			self.viewController?.present(SFSafariViewController(url: url), animated: true)
		}
		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel)
		alert.addAction(okAction)
		alert.addAction(cancelAction)
		self.viewController?.present(alert, animated: true)
	}
}
