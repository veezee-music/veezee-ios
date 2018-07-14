//
//  TrackInAlbumListCollectionViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/2/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class TrackInAlbumListCollectionViewCell: UICollectionViewCell {
	static let ID = "TrackInAlbumListCollectionViewCell";
	
	lazy var indexView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		
		return lb;
	}();
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		lb.textAlignment = .left;
		
		return lb;
	}();
	
	let device = Device();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.cornerRadius = 4;
		
		self.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.addSubview(self.indexView);
		self.indexView.snp.remakeConstraints ({(make) -> Void in
			make.left.equalTo(self.frame.height / (self.device.isPad ? 2 : 3))
			make.centerY.equalToSuperview()
		});
		
		self.addSubview(self.titleView);
		self.titleView.snp.remakeConstraints ({(make) -> Void in
			make.left.equalTo(self.indexView.snp.right).offset(self.frame.height / (self.device.isPad ? 2 : 3))
			make.centerY.equalToSuperview()
			make.width.lessThanOrEqualToSuperview().inset(self.device.isPad ? 50 : 30)
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
