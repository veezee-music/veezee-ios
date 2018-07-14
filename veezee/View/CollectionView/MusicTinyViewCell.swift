//
//  MusicTinyViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

class MusicTinyViewCell : UICollectionViewCell {
	static let ID = "MusicTinyViewCell";
	
	lazy var artworkImageView: UIImageView = {
		let iv = UIImageView(frame: .zero);
		if(Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR) {
			iv.borderWidth = 0.3;
			iv.borderColor = Constants.IMAGES_BORDER_COLOR;
		}
		iv.contentMode = .scaleAspectFill;
		iv.clipsToBounds = true;
		iv.layer.cornerRadius = 4;
		
		return iv;
	}();
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		
		return lb;
	}();
	
	lazy var artistView: UILabel = {
		let lb = UILabel();
		lb.font = lb.font.withSize(13);
		lb.textColor = Constants.SECONDARY_TEXT_COLOR;
		
		return lb;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		let bannerImage = UIImage(named: "artwork")!;
		self.artworkImageView.image = bannerImage;
		self.translatesAutoresizingMaskIntoConstraints = false;
		self.addSubviewOnce(self.artworkImageView);
		
		self.artworkImageView.snp.remakeConstraints({(make) -> Void in
			make.width.height.equalTo(50);
			make.left.equalTo(0);
			make.top.equalTo(0);
		});
		
		self.addSubviewOnce(self.titleView);
		
		self.artistView.textColor = .gray;
		
		let titlesStackView = UIStackView(arrangedSubviews: [titleView, artistView]);
		titlesStackView.axis = .vertical;
		//titlesStackView.alignment = .center
		titlesStackView.distribution = .fill;
		self.addSubviewOnce(titlesStackView);
		titlesStackView.snp.remakeConstraints ({(make) -> Void in
			make.centerY.equalToSuperview()//.offset(10);
			make.left.equalTo(self.artworkImageView.snp.right).offset(10)
			make.right.equalTo(0).offset(10)
		});
		
//		let topBorder: CALayer = CALayer();
//		topBorder.frame = CGRect(x: 0.0, y: -8.0, width: 75 * self.bounds.width / 100, height: 0.3);
//		topBorder.backgroundColor = UIColor.lightGray.cgColor;
//		titlesStackView.layer.addSublayer(topBorder);
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
