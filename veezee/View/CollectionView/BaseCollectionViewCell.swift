//
//  BaseCollectionViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 7/9/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.setupUI();
	}
	
	func setupUI() {
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented");
	}
	
}
