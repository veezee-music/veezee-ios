//
//  TrackInTracksListViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/6/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class TrackInTracksListViewCell: UICollectionViewCell {
	static let ID = "TrackInTracksListViewCell";
	
	static let verticalMargin: CGFloat = 20;
	
	lazy var containerView: UIView = {
		let view = UIView();
		view.cornerRadius = 4;
		view.borderWidth = 1;
		view.borderColor = Constants.PRIMARY_TEXT_COLOR;
		
		return view;
	}();
	
	lazy var albumImageView: UIImageView = {
		let lb = UIImageView();
		lb.clipsToBounds = true;
		lb.layer.cornerRadius = 4;
		lb.image = UIImage(named: "artwork");
		
		return lb;
	}();
	
	lazy var titlesStackView: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [self.titleView, self.artistAndAlbumTitleView]);
		stack.distribution = UIStackView.Distribution.equalCentering;
		stack.axis = .vertical;
		
		return stack;
	}();
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = UIFont.systemFont(ofSize: self.device.isPad ? 25 : 16, weight: UIFont.Weight.bold);
		lb.textAlignment = .left;
		
		return lb;
	}();
	
	lazy var artistAndAlbumTitleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(self.device.isPad ? 18 : 14);
		lb.textAlignment = .left;
		
		return lb;
	}();
	
	let device = Device();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.cornerRadius = 4;
		
		if(self.device.isPad) {
			self.addSubview(self.containerView);
			self.containerView.snp.remakeConstraints({(make) -> Void in
				make.left.right.equalTo(0).offset(70).inset(70)
				make.top.bottom.equalTo(0).offset(TrackInTracksListViewCell.verticalMargin).inset(TrackInTracksListViewCell.verticalMargin)
			});
			self.containerView.layoutIfNeeded();
			
			self.containerView.addSubview(self.albumImageView);
			self.albumImageView.snp.remakeConstraints ({(make) -> Void in
				make.left.equalTo(30)
				make.centerY.equalToSuperview()
				make.width.height.equalTo(120)
			});
			self.albumImageView.layoutIfNeeded();
			
			self.containerView.addSubview(self.titlesStackView);
			self.titlesStackView.snp.remakeConstraints ({ (make) in
				make.left.equalTo(self.albumImageView.snp.right).offset(20)
				make.top.equalTo(self.albumImageView.snp.top).offset(self.albumImageView.frame.height / 4.5)
				make.bottom.equalTo(self.albumImageView.snp.bottom).inset(self.albumImageView.frame.height / 4.5)
				make.right.equalTo(0).inset(20)
			});
		} else {
			self.addSubview(self.containerView);
			self.containerView.snp.remakeConstraints({(make) -> Void in
				make.left.top.right.bottom.equalTo(0).offset(15).inset(15)
			});
			self.containerView.layoutIfNeeded();
			
			self.containerView.addSubview(self.albumImageView);
			self.albumImageView.snp.remakeConstraints ({(make) -> Void in
				make.left.equalTo(10)
				make.centerY.equalToSuperview()
				make.width.height.equalTo(90)
			});
			self.albumImageView.layoutIfNeeded();
			
			self.containerView.addSubview(self.titlesStackView);
			self.titlesStackView.snp.remakeConstraints ({ (make) in
				make.left.equalTo(self.albumImageView.snp.right).offset(15)
				make.top.equalTo(self.albumImageView.snp.top).offset(self.albumImageView.frame.height / 4.5)
				make.bottom.equalTo(self.albumImageView.snp.bottom).inset(self.albumImageView.frame.height / 4.5)
				make.right.equalTo(0).inset(15)
			});
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
