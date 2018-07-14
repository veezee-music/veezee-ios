//
//  MusicSmallViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

class MusicSmallViewCell: UICollectionViewCell {
	
	static let ID = "MusicSmallViewCell";
	
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
		lb.font = lb.font.withSize(16);
		
		return lb;
	}();
	
	lazy var artistView: UILabel = {
		let lb = UILabel();
		lb.font = lb.font.withSize(14);
		lb.textColor = Constants.SECONDARY_TEXT_COLOR;
		
		return lb;
	}();
	
	override func layoutSubviews() {
		super.layoutSubviews();
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let bannerImage = UIImage(named: "artwork")!;
		self.artworkImageView.image = bannerImage;
		
		self.addSubview(self.artworkImageView);
		
		self.artworkImageView.snp.remakeConstraints({(make) -> Void in
			make.width.height.equalTo(self.frame.width)
			make.left.right.equalTo(0)
			make.top.equalTo(0)
		});
		
		self.addSubview(self.titleView);
		self.titleView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.artworkImageView.snp.bottom).offset(5)
			make.width.equalTo(self.frame.width)
			make.left.right.equalTo(0)
		});
		
		self.artistView.textColor = .gray;
		self.addSubview(self.artistView);
		self.artistView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.titleView.snp.bottom)
			make.width.equalTo(self.frame.width)
			make.left.right.equalTo(0)
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
