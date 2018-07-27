//
//  TracksForAlbumCollectionViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import DeviceKit

class TracksForAlbumCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
	static let ID = "TracksForAlbumCollectionViewCell";
	
	weak var navigationDelegate: NavigationControllerDelegate?;
	
	var fullList: [Track] = [];
	var dataList: [Track] = [] {
		didSet {
			self.updateViewHeight();
		}
	}
	var playableList = [PlayableItem]();
	
	static let insetSize: CGFloat = 15;
	
	static let cellHeight: CGFloat = 50;
	static let cellWidth = HorizontalTinyTripleRowCollectionViewCell.cellHeight + 50;
	
	lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = HorizontalTinyTripleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = 0;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: HorizontalTinyTripleRowCollectionViewCell.insetSize, left: 0, bottom: HorizontalTinyTripleRowCollectionViewCell.insetSize, right: 0);
//		collectionViewFlowLayout.itemSize = CGSize(width: 50, height: 50)
//		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: HorizontalTinyTripleRowCollectionViewCell.insetSize, left: HorizontalTinyTripleRowCollectionViewCell.insetSize, bottom: HorizontalTinyTripleRowCollectionViewCell.insetSize, right: HorizontalTinyTripleRowCollectionViewCell.insetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_TEXT_COLOR.withAlphaComponent(0.5);
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = false;
		collectionView.bounces = true;
		collectionView.register(TrackInAlbumListCollectionViewCell.self, forCellWithReuseIdentifier: TrackInAlbumListCollectionViewCell.ID);
		collectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: NoteCollectionViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
		collectionView.layer.cornerRadius = 4;
		
		return collectionView;
	}();
	
	lazy var containerView: UIView = {
		let container = UIView();
		//container.backgroundColor = Constants.PRIMARY_COLOR;
		container.layer.cornerRadius = 4;
		
		return container;
	}();
	
	lazy var innerContainerView: UIView = {
		let container = UIView();
		container.backgroundColor = Constants.PRIMARY_COLOR;
		container.layer.cornerRadius = 4;
		container.layer.zPosition = 2;
		
		return container;
	}();
	
	lazy var albumTitleView: UILabel = {
		let albumTitleView = UILabel();
		albumTitleView.font = UIFont.systemFont(ofSize: self.device.isPad ? 30 : 20, weight: UIFont.Weight.bold);
		albumTitleView.textColor = Constants.PRIMARY_TEXT_COLOR;
		
		return albumTitleView;
	}();
	
	lazy var albumArtistView: UILabel = {
		let albumArtistView = UILabel();
		albumArtistView.font = UIFont.systemFont(ofSize: self.device.isPad ? 25 : 15, weight: UIFont.Weight.regular);
		albumArtistView.textColor = Constants.PRIMARY_TEXT_COLOR;
		
		return albumArtistView;
	}();
	
	lazy var albumImageView: UIImageView = {
		let albumImageView = UIImageView();
		albumImageView.clipsToBounds = true;
		albumImageView.layer.cornerRadius = 4;
		albumImageView.image = UIImage(named: "artwork");
		
		return albumImageView;
	}();
	
	let device = Device();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.addSubview(self.containerView);
		self.containerView.snp.remakeConstraints({(make) -> Void in
			make.left.right.top.bottom.equalTo(0)
		});
		self.containerView.layoutIfNeeded();
		
		if(self.device.isPad) {
			self.containerView.addSubview(self.innerContainerView);
			self.innerContainerView.snp.remakeConstraints({(make) -> Void in
				make.left.right.equalTo(0).offset(70).inset(70)
				make.top.bottom.equalTo(0).offset(40).inset(40)
			});
			self.innerContainerView.layoutIfNeeded();
			
			self.innerContainerView.addSubview(self.albumImageView);
			self.albumImageView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(-20)
				make.left.equalTo(20)
				make.width.height.equalTo(130)
			});
			
			self.innerContainerView.addSubview(albumTitleView);
			albumTitleView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(0).offset(15)
				make.left.equalTo(albumImageView.snp.right).offset(15)
				make.right.equalTo(0).inset(15)
			});
			
			self.innerContainerView.addSubview(albumArtistView);
			albumArtistView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(albumTitleView.snp.bottom).offset(10)
				make.left.equalTo(albumImageView.snp.right).offset(15)
				make.right.equalTo(0).inset(15)
			});
		} else {
			self.containerView.addSubview(self.innerContainerView);
			self.innerContainerView.snp.remakeConstraints({(make) -> Void in
				make.left.top.right.bottom.equalTo(0).offset(15).inset(15)
			});
			self.innerContainerView.layoutIfNeeded();
			
			self.innerContainerView.addSubview(self.albumImageView);
			self.albumImageView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(-10)
				make.left.equalTo(10)
				make.width.height.equalTo(110)
			});
			
			self.innerContainerView.addSubview(albumTitleView);
			albumTitleView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(0).offset(15)
				make.left.equalTo(albumImageView.snp.right).offset(15)
				make.right.equalTo(0).inset(15)
			});
			
			self.innerContainerView.addSubview(albumArtistView);
			albumArtistView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(albumTitleView.snp.bottom).offset(10)
				make.left.equalTo(albumImageView.snp.right).offset(15)
				make.right.equalTo(0).inset(15)
			});
		}
	}
	
	func updateViewHeight() {
		if(self.device.isPad) {
			self.innerContainerView.addSubview(self.collectionView);
			self.collectionView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(albumImageView.snp.bottom).offset(30)
				make.left.right.equalTo(0).offset(30).inset(30)
				make.height.equalTo(CGFloat(self.dataList.count) * 50.0 + TracksForAlbumCollectionViewCell.insetSize * (CGFloat(self.dataList.count) + 1.0))
			});
			self.collectionView.layoutIfNeeded();
			
			self.innerContainerView.snp.remakeConstraints({(make) -> Void in
				make.left.right.equalTo(0).offset(70).inset(70)
				make.top.bottom.equalTo(0).offset(40).inset(40)
				make.bottom.equalTo(self.collectionView.snp.bottom).offset(30)
			});
			self.innerContainerView.layoutIfNeeded();
			
			let backgroundForFakeBorder = UIView();
			backgroundForFakeBorder.layer.zPosition = 1;
			backgroundForFakeBorder.cornerRadius = 4;
			backgroundForFakeBorder.backgroundColor = Constants.PRIMARY_TEXT_COLOR;
			self.containerView.addSubview(backgroundForFakeBorder);
			backgroundForFakeBorder.snp.remakeConstraints({(make) -> Void in
				make.left.right.equalTo(0).offset(69).inset(69)
				make.top.bottom.equalTo(0).offset(39).inset(39)
				make.bottom.equalTo(self.collectionView.snp.bottom).offset(31)
			});
			backgroundForFakeBorder.isUserInteractionEnabled = false;
		} else {
			self.innerContainerView.addSubview(self.collectionView);
			self.collectionView.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(albumImageView.snp.bottom).offset(20)
				make.left.right.equalTo(0).offset(20).inset(20)
				make.height.equalTo(CGFloat(self.dataList.count) * 50.0 + TracksForAlbumCollectionViewCell.insetSize * (CGFloat(self.dataList.count) + 1.0))
			});
			self.collectionView.layoutIfNeeded();
			
			self.innerContainerView.snp.remakeConstraints({(make) -> Void in
				make.left.top.right.equalTo(0).offset(15).inset(15)
				make.bottom.equalTo(self.collectionView.snp.bottom).offset(20)
			});
			self.innerContainerView.layoutIfNeeded();
			
			let backgroundForFakeBorder = UIView();
			backgroundForFakeBorder.layer.zPosition = 1;
			backgroundForFakeBorder.cornerRadius = 4;
			backgroundForFakeBorder.backgroundColor = Constants.PRIMARY_TEXT_COLOR;
			self.containerView.addSubview(backgroundForFakeBorder);
			backgroundForFakeBorder.snp.remakeConstraints({(make) -> Void in
				make.left.top.right.equalTo(0).offset(14).inset(14)
				make.bottom.equalTo(self.collectionView.snp.bottom).offset(21)
			});
			backgroundForFakeBorder.isUserInteractionEnabled = false;
		}
		
		self.collectionView.reloadData();
		
//		gradientLayer?.removeFromSuperlayer();
//		if(self.dataList.count > 10) {
//			self.applyFadingGradient();
//		}
	}
	
	var gradientLayer: CAGradientLayer?;
	func applyFadingGradient() {
		gradientLayer = CAGradientLayer();
		gradientLayer!.frame = self.collectionView.bounds;
		gradientLayer!.colors = [UIColor.clear.cgColor, UIColor.white.cgColor];
		self.collectionView.layer.addSublayer(gradientLayer!);
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.init();
	}
}

extension TracksForAlbumCollectionViewCell: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if(self.fullList.count > self.dataList.count && indexPath.item == (self.dataList.count - 1)) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCollectionViewCell.ID, for: indexPath) as! NoteCollectionViewCell;
			cell.titleView.text = "+\(self.fullList.count - self.dataList.count + 1) More";
			
			return cell;
		} else {
			let item = self.dataList[indexPath.item];
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackInAlbumListCollectionViewCell.ID, for: indexPath) as! TrackInAlbumListCollectionViewCell;
			
			cell.titleView.text = item.title;
			cell.indexView.text = String(indexPath.item + 1);
			
			return cell;
		}
	}
	
}

extension TracksForAlbumCollectionViewCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.collectionView.frame.width - (self.device.isPad ? 100 : 30), height: 50);
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if(self.fullList.count > self.dataList.count) {
 			return self.dataList.count + 1;
		} else {
			return self.dataList.count;
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if(self.fullList.count > self.dataList.count && indexPath.item == (self.dataList.count - 1)) {
			if(self.dataList.first != nil && self.dataList.first!.album != nil) {
				self.navigationDelegate?.navigateToVCFor(album: self.dataList.first!.album!);
			}
		} else {
//			let item = self.dataList[indexPath.item];
			
			self.playableList = generatePlayableListFromTracksList(list: self.fullList);
			NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : self.playableList, "currentPlayableItemIndex": indexPath.item]);
		}
	}
	
}

private class NoteCollectionViewCell: UICollectionViewCell {
	static let ID = "NoteCollectionViewCell";
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_COLOR;
		lb.font = lb.font.withSize(17);
		lb.textAlignment = .center;
		
		return lb;
	}();
	
	let device = Device();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.cornerRadius = 4;
		
		self.backgroundColor = UIColor.clear;
		
		self.addSubview(self.titleView);
		self.titleView.snp.makeConstraints ({(make) -> Void in
			make.centerY.equalToSuperview()
			make.width.equalToSuperview()
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
