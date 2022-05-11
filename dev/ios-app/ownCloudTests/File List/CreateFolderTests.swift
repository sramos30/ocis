//
//  CreateFolderTests.swift
//  ownCloudTests
//
//  Created by Javier Gonzalez on 08/01/2019.
//  Copyright © 2019 ownCloud GmbH. All rights reserved.
//

import XCTest
import EarlGrey
import ownCloudSDK
import ownCloudMocking

@testable import ownCloud

class CreateFolderTests: FileTests {

	let hostSimulator: OCHostSimulator = OCHostSimulator()

	/*
	* PASSED if: Create Folder view is shown
	*/
	func testShowCreateFolder() {

		if let bookmark: OCBookmark = UtilsTests.getBookmark() {
			//Mocks
			self.mockQueryPropfindResults(resourceName: "PropfindResponse", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)
			self.showFileList(bookmark: bookmark)

			//Actions
			EarlGrey.selectElement(with: grey_accessibilityID("client.file-add")).perform(grey_tap())
			EarlGrey.selectElement(with: grey_text("Create folder".localized)).perform(grey_tap())

			//Asserts
			EarlGrey.selectElement(with: grey_accessibilityID("name-text-field")).assert(grey_sufficientlyVisible())

			//Remove Mocks
			OCMockManager.shared.removeAllMockingBlocks()

			//Reset status
			EarlGrey.selectElement(with: grey_accessibilityID("cancel-button")).perform(grey_tap())
			dismissFileList()
		} else {
			assertionFailure("File list not loaded because Bookmark is nil")
		}
	}

	/*
	* PASSED if: A folder is created
	*/
	func testCreateFolder() {

		if let bookmark: OCBookmark = UtilsTests.getBookmark() {

			let folderName = "New Folder"

			//Mocks
			self.mockQueryPropfindResults(resourceName: "PropfindResponse", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)
			self.showFileList(bookmark: bookmark)

			//Actions
			EarlGrey.selectElement(with: grey_accessibilityID("client.file-add")).perform(grey_tap())
			EarlGrey.selectElement(with: grey_text("Create folder".localized)).perform(grey_tap())

			//Remove Mocks
			OCMockManager.shared.removeMockingBlock(atLocation: OCMockLocation.ocQueryRequestChangeSetWithFlags)

			//Mock again
			self.mockQueryPropfindResults(resourceName: "PropfindResponseNewFolder", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)

			EarlGrey.selectElement(with: grey_accessibilityID("name-text-field")).perform(grey_replaceText(folderName))
			EarlGrey.selectElement(with: grey_accessibilityID("done-button")).perform(grey_tap())

			//Assert
			let isFolderCreated = GREYCondition(name: "Wait for folder is created", block: {
				var error: NSError?

				EarlGrey.selectElement(with: grey_accessibilityID(folderName)).assert(grey_sufficientlyVisible(), error: &error)

				return error == nil
			}).wait(withTimeout: 5.0, pollInterval: 0.5)

			GREYAssertTrue(isFolderCreated, reason: "Failed to create the folder")

			//Remove Mocks
			OCMockManager.shared.removeAllMockingBlocks()

			//Reset status
			dismissFileList()

		} else {
			assertionFailure("File list not loaded because Bookmark is nil")
		}
	}

	/*
	* PASSED if: Done button is disabled with empty name
	*/
	func testDisableButtonCreateFolderWithEmptyName() {

		if let bookmark: OCBookmark = UtilsTests.getBookmark() {

			let folderName = ""

			//Mocks
			self.mockQueryPropfindResults(resourceName: "PropfindResponse", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)
			self.showFileList(bookmark: bookmark)

			//Actions
			EarlGrey.selectElement(with: grey_accessibilityID("client.file-add")).perform(grey_tap())
			EarlGrey.selectElement(with: grey_text("Create folder".localized)).perform(grey_tap())

			//Remove Mocks
			OCMockManager.shared.removeMockingBlock(atLocation: OCMockLocation.ocQueryRequestChangeSetWithFlags)

			//Mock again
			self.mockQueryPropfindResults(resourceName: "PropfindResponseNewFolder", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)

			EarlGrey.selectElement(with: grey_accessibilityID("name-text-field")).perform(grey_replaceText(folderName))

			//Assert
			EarlGrey.selectElement(with: grey_accessibilityID("done-button")).assert(grey_not(grey_enabled()))

			//Remove Mocks
			OCMockManager.shared.removeAllMockingBlocks()

			//Reset status
			EarlGrey.selectElement(with: grey_accessibilityID("cancel-button")).perform(grey_tap())
			dismissFileList()
		} else {
			assertionFailure("File list not loaded because Bookmark is nil")
		}
	}

	/*
	* PASSED if: Done button is enabled with a valid name
	*/
	func testEnableButtonCreateFolderWithValidName() {

		if let bookmark: OCBookmark = UtilsTests.getBookmark() {

			let folderName = "Valid Name"

			//Mocks
			self.mockQueryPropfindResults(resourceName: "PropfindResponse", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)
			self.showFileList(bookmark: bookmark)

			//Actions
			EarlGrey.selectElement(with: grey_accessibilityID("client.file-add")).perform(grey_tap())
			EarlGrey.selectElement(with: grey_text("Create folder".localized)).perform(grey_tap())

			//Remove Mocks
			OCMockManager.shared.removeMockingBlock(atLocation: OCMockLocation.ocQueryRequestChangeSetWithFlags)

			//Mock again
			self.mockQueryPropfindResults(resourceName: "PropfindResponseNewFolder", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)

			EarlGrey.selectElement(with: grey_accessibilityID("name-text-field")).perform(grey_replaceText(folderName))

			//Assert
			EarlGrey.selectElement(with: grey_accessibilityID("done-button")).assert(grey_enabled())

			//Remove Mocks
			OCMockManager.shared.removeAllMockingBlocks()

			//Reset status
			EarlGrey.selectElement(with: grey_accessibilityID("cancel-button")).perform(grey_tap())
			dismissFileList()
		} else {
			assertionFailure("File list not loaded because Bookmark is nil")
		}
	}

	/*
	* PASSED if: Done if Forbidden Characters Alert appears
	*/
	func testCreateFolderWithInvalidCharacters() {

		if let bookmark: OCBookmark = UtilsTests.getBookmark() {

			let folderName = "New/Folder"

			//Mocks
			self.mockQueryPropfindResults(resourceName: "PropfindResponse", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)
			self.showFileList(bookmark: bookmark)

			//Actions
			EarlGrey.selectElement(with: grey_accessibilityID("client.file-add")).perform(grey_tap())
			EarlGrey.selectElement(with: grey_text("Create folder".localized)).perform(grey_tap())

			//Remove Mocks
			OCMockManager.shared.removeMockingBlock(atLocation: OCMockLocation.ocQueryRequestChangeSetWithFlags)

			//Mock again
			self.mockQueryPropfindResults(resourceName: "PropfindResponseNewFolder", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)

			EarlGrey.selectElement(with: grey_accessibilityID("name-text-field")).perform(grey_replaceText(folderName))
			EarlGrey.selectElement(with: grey_accessibilityID("done-button")).perform(grey_tap())

			//Assert
			EarlGrey.selectElement(with: grey_accessibilityID("forbidden-characters-alert")).assert(grey_sufficientlyVisible())

			//Remove Mocks
			OCMockManager.shared.removeAllMockingBlocks()

			//Reset status
			EarlGrey.selectElement(with: grey_text("OK".localized)).perform(grey_tap())
			EarlGrey.selectElement(with: grey_accessibilityID("cancel-button")).perform(grey_tap())
			dismissFileList()
		} else {
			assertionFailure("File list not loaded because Bookmark is nil")
		}
	}

	/*
	* PASSED if: Error is shown on the view
	*/
	func testCreateFolderWithExistingName() {
		if let bookmark: OCBookmark = UtilsTests.getBookmark() {

			let folderName = "New Folder"
			let errorTitle = "Error title"
			let errorMessage = "Error message"

			//Mocks
			self.mockQueryPropfindResults(resourceName: "PropfindResponseNewFolder", basePath: "/remote.php/dav/files/admin", state: .contentsFromCache)

			let issue: OCIssue = OCIssue(forMultipleChoicesWithLocalizedTitle: errorTitle, localizedDescription: errorMessage, choices: [OCIssueChoice(type: .cancel, identifier: nil, label: "Cancel".localized, userInfo: nil, handler: nil)]) { (issue, decission) in
			}

			self.showFileList(bookmark: bookmark, issue: issue)

			//Actions
			EarlGrey.selectElement(with: grey_accessibilityID("client.file-add")).perform(grey_tap())
			EarlGrey.selectElement(with: grey_text("Create folder".localized)).perform(grey_tap())

			EarlGrey.selectElement(with: grey_accessibilityID("name-text-field")).perform(grey_replaceText(folderName))
			EarlGrey.selectElement(with: grey_accessibilityID("done-button")).perform(grey_tap())

			//Assert
			EarlGrey.waitForElement(withMatcher: grey_text(errorTitle), label: errorTitle)
			EarlGrey.selectElement(with: grey_text(errorTitle)).assert(grey_sufficientlyVisible())
			EarlGrey.selectElement(with: grey_text(errorMessage)).assert(grey_sufficientlyVisible())

			//Remove Mocks
			OCMockManager.shared.removeAllMockingBlocks()

			//Reset status
			EarlGrey.selectElement(with: grey_text("Cancel".localized)).atIndex(0).perform(grey_tap())
			dismissFileList()

		} else {
			assertionFailure("File list not loaded because Bookmark is nil")
		}
	}
}
