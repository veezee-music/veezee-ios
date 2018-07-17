//
//  ActionSheetCustomButton.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 5/14/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class ActionSheetCustomButton: ActionSheetButton {
	
	
	// MARK: - Initialization
	
	override var value: Any? {
		get {
			return super.value;
		}
		set {
			super.value = newValue;
		}
	}
	
	public init(title: String, value: String?) {
		super.init(title: title, value: nil)
		
		self.value = value;
	}
	
	
	// MARK: - Functions
	
	open override func applyAppearance(_ appearance: ActionSheetAppearance) {
		self.appearance = ActionSheetButtonAppearance(copy: appearance.okButton)
	}
	
	open override func applyAppearance(to cell: UITableViewCell) {
		super.applyAppearance(to: cell)
		cell.textLabel?.textAlignment = .center
	}
}
