//
//  UIDevice+UIUserInterfaceIdiom.swift
//  ownCloud
//
//  Created by Pablo Carrascal on 05/06/2018.
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

public extension UIDevice {
	var isIpad : Bool {
		if self.userInterfaceIdiom == .pad {
			return true
		}

		return false
	}
}
