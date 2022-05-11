//
//  MockOCQuery.swift
//  ownCloudTests
//
//  Created by Javier Gonzalez on 08/01/2019.
//  Copyright © 2019 ownCloud GmbH. All rights reserved.
//

import UIKit
import ownCloudSDK

class MockOCQuery: OCQuery {

	convenience init(path: String) {
		self.init(forPath: path)
		let rootItem = OCItem()
		rootItem.permissions = [.createFile, .createFolder, .delete, .move, .rename, .writable]
		rootItem.path = "/"
		rootItem.type = OCItemType.collection
		self.rootItem = rootItem
	}
}
