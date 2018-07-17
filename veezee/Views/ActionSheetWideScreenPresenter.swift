//
//  ActionSheetWideScreenPresenter.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 5/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import Sheeeeeeeeet

class iPadActionSheet: ActionSheet {
	
	override init(
		items: [ActionSheetItem],
		presenter: ActionSheetPresenter = ActionSheet.defaultPresenter,
		action: @escaping ActionSheetItemSelectAction) {
		super.init(items: items, presenter: presenter, action: action);
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	override func margin(at margin: ActionSheetMargin) -> CGFloat {
		switch margin {
		case .left:
			return self.view.superview!.frame.width / 4.5;
		case .right:
			return self.view.superview!.frame.width / 4.5;
		default:
			return super.margin(at: margin);
		}
	}
	
}
