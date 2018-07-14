//
//  GenreTinyViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/2/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit

class GenreTinyViewCell : UICollectionViewCell {
	static let ID = "GenreTinyViewCell";
	
	lazy var imageView: UIImageView = {
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
	
	override func layoutSubviews() {
		super.layoutSubviews();
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		let bannerImage = UIImage(named: "artwork")!;
		self.imageView.image = bannerImage;
		self.addSubview(self.imageView);
		
		self.imageView.snp.makeConstraints({(make) -> Void in
			make.width.height.equalTo(self.frame.width);
			make.top.equalTo(0);
		});
		
		self.addSubview(self.titleView);
		self.titleView.textAlignment = .center;
		
		self.titleView.snp.makeConstraints ({(make) -> Void in
			make.top.equalTo(self.imageView.snp.bottom).offset(5)
			make.left.right.equalTo(0)
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
