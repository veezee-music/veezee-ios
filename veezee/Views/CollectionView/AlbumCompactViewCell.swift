//
//  AlbumCompactViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 10/18/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit

class AlbumCompactViewCell: UICollectionViewCell {
	static let ID = "AlbumCompactViewCell";
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		
		return lb;
	}();
	
	lazy var trackCountView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		lb.textAlignment = .right;
		
		return lb;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.backgroundColor = Constants.SECONDARY_TEXT_COLOR.withAlphaComponent(0.6);
		self.layer.cornerRadius = 4;
		
		self.addSubview(self.trackCountView);
		self.trackCountView.snp.remakeConstraints { make in
			make.right.equalTo(0).inset(10)
			make.centerY.equalToSuperview()
			make.width.greaterThanOrEqualTo(90)
		}
		self.trackCountView.layoutIfNeeded();
		
		self.addSubviewOnce(self.titleView);
		self.titleView.snp.remakeConstraints { make in
			make.left.equalTo(10)
			make.right.equalTo(self.trackCountView.snp.left).inset(-10)
			make.centerY.equalToSuperview()
		}
		self.titleView.layoutIfNeeded();
		
		//		let topBorder: CALayer = CALayer();
		//		topBorder.frame = CGRect(x: 0.0, y: -8.0, width: 75 * self.bounds.width / 100, height: 0.3);
		//		topBorder.backgroundColor = UIColor.lightGray.cgColor;
		//		titlesStackView.layer.addSublayer(topBorder);
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
