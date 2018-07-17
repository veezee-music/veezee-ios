//
//  IconedButton.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 5/6/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import SwiftIcons

class IconedButton: UIButton {
	
	var icon: FontType?;
	var iconSize: CGFloat?;
	var buttonBackgroundColor: UIColor?;
	var iconColor: UIColor?;
	
	init() {
		super.init(frame: .zero);
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame);
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	func initButton(icon: FontType, iconSize: CGFloat?, color: UIColor, backgroundColor: UIColor, forState state: UIControlState) {
		self.icon = icon;
		self.iconSize = iconSize;
		self.buttonBackgroundColor = backgroundColor;
		self.iconColor = color;
		super.setIcon(icon: icon, iconSize: iconSize, color: color, backgroundColor: backgroundColor, forState: .normal);
	}
	
	func initButton(icon: FontType, iconSize: CGFloat?, color: UIColor, forState state: UIControlState) {
		self.icon = icon;
		self.iconSize = iconSize;
		self.iconColor = color;
		super.setIcon(icon: icon, iconSize: iconSize, color: color, forState: .normal);
	}
	
	func setIcon(icon: FontType) {
		self.icon = icon;
		self.setIcon(icon: self.icon!, iconSize: self.iconSize!, color: self.iconColor!, forState: .normal);
	}
	
	func setIcon(icon: FontType, color: UIColor) {
		self.icon = icon;
		self.iconColor = color;
		self.setIcon(icon: self.icon!, iconSize: self.iconSize!, color: self.iconColor!, forState: .normal);
	}
	
	func setIcon(icon: FontType, color: UIColor, forState state: UIControlState) {
		self.icon = icon;
		self.iconColor = color;
		self.setIcon(icon: self.icon!, iconSize: self.iconSize!, color: self.iconColor!, forState: state);
	}
	
	func setIcon(color: UIColor, forState state: UIControlState) {
		self.iconColor = color;
		self.setIcon(icon: self.icon!, iconSize: self.iconSize!, color: self.iconColor!, forState: state);
	}
	
}
