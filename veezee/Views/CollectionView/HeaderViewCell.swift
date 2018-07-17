//
//  HeaderViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class HeaderViewCell : UICollectionViewCell {
	static let ID = "HeaderViewCell";
	
	private let device = Device();
	
	lazy var artworkImageView: UIImageView = {
		let iv = UIImageView(frame: .zero);
		iv.contentMode = .scaleAspectFill;
		iv.clipsToBounds = true;
		iv.layer.cornerRadius = 4;
		
		return iv;
	}();
	
	lazy var descriptionView : UILabel = {
		let descriptionView = UILabel()
		descriptionView.textColor = Constants.ACCENT_COLOR;
		descriptionView.font = descriptionView.font.withSize(13);
		
		return descriptionView;
	}();
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(21);
		
		return lb;
	}();
	
	lazy var artistView: UILabel = {
		let lb = UILabel();
		lb.font = lb.font.withSize(17);
		lb.textColor = .gray;
		
		return lb;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.setupUI();
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HeaderViewCell {
	
//	override func layoutSubviews() {
//		super.layoutSubviews();
//		
//		print("fff")
//		self.setupUI();
//	}
	
	func setupUI() {
		let magicPercentage: CGFloat = self.device.isPad ? 75.0 : 83.0;
		let width = UIScreen.main.bounds.width * magicPercentage / 100;
		let height = width / 1.8;
		
		self.addSubviewOnce(self.descriptionView);
		self.descriptionView.snp.remakeConstraints({(make) -> Void in
			make.top.lessThanOrEqualTo(20);
			make.left.right.equalTo(0)
		});
		
		self.addSubviewOnce(self.titleView);
		self.titleView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.descriptionView.snp.bottom)
			make.left.right.equalTo(0)
		});
		
		self.artistView.textColor = .gray;
		self.addSubviewOnce(self.artistView);
		self.artistView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.titleView.snp.bottom)
			make.left.right.equalTo(0)
		});
		
		let bannerImage = UIImage(named: "header")!;
		self.artworkImageView.image = bannerImage;
		self.addSubviewOnce(self.artworkImageView);
		self.artworkImageView.snp.remakeConstraints({(make) -> Void in
			make.left.right.equalTo(0)
			make.height.equalTo(height)
			make.top.equalTo(self.artistView.snp.bottom).offset(10);
			make.bottom.equalTo(0)
		});
	}
	
}
