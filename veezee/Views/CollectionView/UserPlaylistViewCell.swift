//
//  UserPlaylistViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

class UserPlaylistViewCell: UICollectionViewCell {
	static let ID = "UserPlaylistViewCell";
	
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
		lb.textColor = Constants.WHITE_THEME.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(16);
		
		return lb;
	}();
	
	lazy var noteView: UILabel = {
		let lb = UILabel();
		lb.font = lb.font.withSize(20);
		lb.textColor = Constants.WHITE_THEME.SECONDARY_TEXT_COLOR;
		
		return lb;
	}();
	
	lazy var checkIconView: UIButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosCheckmark), iconSize: 20, color: .red, forState: .normal);
		button.alpha = 0;
		
		return button;
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
			make.top.equalTo(self.artworkImageView.snp.bottom).offset(10)
			make.width.equalTo(self.frame.width)
			make.left.right.equalTo(0)
		});
		
		self.noteView.textColor = .gray;
		self.addSubview(self.noteView);
		self.noteView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.titleView.snp.bottom).offset(5)
			make.width.lessThanOrEqualTo(self.frame.width)
			make.left.equalTo(0)
			make.height.equalTo(20)
		});
		
		self.addSubview(self.checkIconView);
		self.checkIconView.snp.remakeConstraints({(make) -> Void in
			make.right.equalTo(0)
			make.left.equalTo(noteView.snp.right)
			make.top.equalTo(self.titleView.snp.bottom).offset(5)
			make.height.equalTo(20)
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
