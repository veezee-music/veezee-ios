//
//  UniversalActionSheet.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 5/20/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import Sheeeeeeeeet
import DeviceKit

class UniversalActionSheet {
	
	private let device = Device();
	public var sheet: ActionSheet?;
	
	init(
		items: [ActionSheetItem],
		presenter: ActionSheetPresenter = ActionSheet.defaultPresenter,
		action: @escaping ActionSheetItemSelectAction) {
		if(self.device.isPad) {
			self.sheet = iPadActionSheet(items: items, action: action);
		} else {
			self.sheet = ActionSheet(items: items, action: action);
		}
	}
	
}
