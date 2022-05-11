//
//  ownCloudTests.swift
//  ownCloudTests
//
//  Created by Pablo Carrascal on 07/03/2018.
//  Copyright © 2018 ownCloud. All rights reserved.
//

import XCTest
import EarlGrey

@testable import ownCloud

class OwnCloudTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*
     * Passed if: "Add account" button is enabled
     */
    func testAddServerButtonIsEnabled() {
	EarlGrey.waitForElement(accessibilityID: "addServer")
        EarlGrey.selectElement(with: grey_accessibilityID("addServer")).assert( grey_enabled())
    }

    func testClickOnTheButtonAndNothingHappens() {
	EarlGrey.waitForElement(accessibilityID: "addServer")
        EarlGrey.selectElement(with: grey_accessibilityID("addServer")).perform(grey_tap())
	EarlGrey.waitForElement(accessibilityID: "cancel")
        EarlGrey.selectElement(with: grey_accessibilityID("cancel")).perform(grey_tap())
    }
}
