//
//  LightButtonWithBackground.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/16/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit

class LightButtonWithBackground: UIButton {

//	override open var isHighlighted: Bool {
//		didSet {
//			backgroundColor = isHighlighted ? Constants.LIGHT_BUTTON_HIGHLIGHT : Constants.LIGHT_BUTTON_BACKGROUND;
//		}
//	}
	
	private let animationDuration: TimeInterval = 0.2
	
	@IBInspectable
	var animatedColorChange: Bool = true
	
	@IBInspectable
	var selectedBgColor = Constants.PRIMARY_TEXT_COLOR.withAlphaComponent(0.5);
	
	@IBInspectable
	var normalBgColor = Constants.PRIMARY_COLOR;
	
	override var isSelected: Bool {
		didSet {
			if animatedColorChange {
				UIView.animate(withDuration: self.animationDuration) {
					self.backgroundColor = self.isSelected ? self.selectedBgColor : self.normalBgColor
				}
			} else {
				self.backgroundColor = isSelected ? selectedBgColor : normalBgColor
			}
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			if animatedColorChange {
				UIView.animate(withDuration: self.animationDuration) {
					self.backgroundColor = self.isHighlighted ? self.selectedBgColor : self.normalBgColor
				}
			} else {
				self.backgroundColor = isHighlighted ? selectedBgColor : normalBgColor
			}
		}
	}

}
