//
//  MusicSearchItemViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 7/7/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class MusicSearchItemViewCell: UICollectionViewCell {
	static let ID = "MusicSearchItemViewCell";
	
	let device = Device();
	
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
		lb.font = lb.font.withSize(self.device.isPad ? 20 : 17);
		
		return lb;
	}();
	
	lazy var artistView: UILabel = {
		let lb = UILabel();
		lb.font = lb.font.withSize(14);
		lb.textColor = Constants.SECONDARY_TEXT_COLOR;
		
		return lb;
	}();
	
	lazy var albumPlaylistView: UILabel = {
		let lb = UILabel();
		lb.font = lb.font.withSize(14);
		lb.textColor = Constants.SECONDARY_TEXT_COLOR;
		
		return lb;
	}();
	
	lazy var goToAlbumPlaylist: UIButton = {
		let button = UIButton();
		button.setIcon(icon: .ionicons(.iosArrowRight), iconSize: 20, color: Constants.SECONDARY_TEXT_COLOR, forState: .normal);
		//		button.addTarget(self, action: .skipForwardButtonPressed, for: .touchUpInside);
		
		return button;
	}();
	
	lazy var titlesStackView: UIStackView = {
		let titlesStackView = UIStackView(arrangedSubviews: [titleView, artistView, albumPlaylistView]);
		titlesStackView.axis = .vertical;
		//titlesStackView.alignment = .center
		titlesStackView.distribution = .fill;
		titlesStackView.spacing = 5;
		
		return titlesStackView;
	}();
	
	override func layoutSubviews() {
		super.layoutSubviews();
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		let bannerImage = UIImage(named: "artwork")!;
		self.artworkImageView.image = bannerImage;
		self.translatesAutoresizingMaskIntoConstraints = false;
		self.addSubview(self.artworkImageView);
		
		self.artworkImageView.snp.makeConstraints({(make) -> Void in
			make.width.height.equalTo(80);
			make.left.equalTo(0);
			make.top.equalTo(0);
		});
		
		self.addSubview(self.titleView);
		
		self.artistView.textColor = .gray;
		
		self.addSubview(titlesStackView);
		self.titlesStackView.snp.makeConstraints ({(make) -> Void in
			make.centerY.equalToSuperview()
			make.left.equalTo(self.artworkImageView.snp.right).offset(15)
			make.right.equalTo(0).inset(30)
		});
		
		self.addSubview(self.goToAlbumPlaylist);
		self.goToAlbumPlaylist.snp.makeConstraints ({(make) -> Void in
			make.centerY.equalToSuperview()
			make.right.equalTo(0).inset(self.device.isPad ? 5 : 0)
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
