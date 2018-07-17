//
//  SearchRowAlbumsCollectionViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 7/7/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class SearchRowAlbumsCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	static let ID = "SearchRowAlbumsCollectionViewCell";
	
	weak var navigationDelegate: NavigationControllerDelegate?;
	
	let device = Device();
	
	private var _dataList = [Album]();
	var dataList: [Album] {
		set {
			_dataList = newValue;
			self.collectionView.reloadData();
		}
		get { return _dataList }
	}
	
	let musicSmallCardInsetSize: CGFloat = 15;
	
	let musicSmallCardSideSizeHorizontal: CGFloat = 50;
	lazy var musicSmallCardSideSizeVertical = musicSmallCardSideSizeHorizontal + 50;
	
	lazy var collectionViewFlowLayout : SnappingCollectionViewFlowLayout = {
		let collectionViewFlowLayout = SnappingCollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = self.musicSmallCardInsetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = 0//self.musicSmallCardInsetSize / 2;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: self.musicSmallCardInsetSize, left: self.musicSmallCardInsetSize, bottom: self.musicSmallCardInsetSize, right: self.musicSmallCardInsetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(MusicSearchItemViewCell.self, forCellWithReuseIdentifier: MusicSearchItemViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.translatesAutoresizingMaskIntoConstraints = false;
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
		
		return collectionView;
	}();
	
	lazy var collectionViewTitleView : UILabel = {
		let latestMusicsLabel = UILabel();
		latestMusicsLabel.translatesAutoresizingMaskIntoConstraints = false;
		latestMusicsLabel.textColor = Constants.PRIMARY_TEXT_COLOR;
		//let boldFont = UIFont.preferredFont(forTextStyle: .largeTitle);
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		latestMusicsLabel.font = boldFont.withSize(20);
		
		return latestMusicsLabel;
	}();
	
	lazy var collectionViewSeeAllView : UIButton = {
		let latestMusicsSeeAllButton = UIButton();
		latestMusicsSeeAllButton.translatesAutoresizingMaskIntoConstraints = false;
		latestMusicsSeeAllButton.titleLabel?.font = latestMusicsSeeAllButton.titleLabel?.font.withSize(15);
		latestMusicsSeeAllButton.setTitle("See All", for: .normal);
		latestMusicsSeeAllButton.setTitleColor(Constants.SECONDARY_TEXT_COLOR, for: .normal);
		
		return latestMusicsSeeAllButton;
	}();
	
	lazy var headingsDividerView : UIView = {
		let headingsDivider = UIView();
		
		return headingsDivider;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.addSubview(self.collectionViewTitleView);
		
		self.collectionViewTitleView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(0).offset(self.musicSmallCardInsetSize - 5);
			make.left.equalTo(0)
			make.height.equalTo(25);
		});
		
		self.addSubview(self.collectionViewSeeAllView);
		
		self.collectionViewSeeAllView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(0).offset(self.musicSmallCardInsetSize - 5);
			make.right.equalTo(0)
			make.height.equalTo(25);
		});
		
		self.addSubview(self.headingsDividerView);
		
		self.headingsDividerView.snp.makeConstraints({(make) -> Void in
			make.height.equalTo(1);
			make.width.equalToSuperview();
			make.top.equalTo(self.collectionViewTitleView.snp.bottom).offset(10);
		});
		
		self.addSubview(self.collectionView);
		self.collectionView.snp.makeConstraints({(make) -> Void in
			make.width.equalToSuperview();
			//make.height.equalTo(6 * 80)
			make.top.equalTo(self.headingsDividerView.snp.bottom);
			make.left.right.equalTo(0);
			make.bottom.equalTo(0)
		});
		self.collectionView.layer.cornerRadius = 4;
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicSearchItemViewCell.ID, for: indexPath) as! MusicSearchItemViewCell;
		let item = self.dataList[indexPath.item];
		
		if(item.image != nil && item.image != "") {
			cell.artworkImageView.kf.setImage(with: URL(string: (item.image)!), placeholder: UIImage(named: "artwork"));
		} else {
			cell.artworkImageView.image = UIImage(named: "artwork");
		}
		
		cell.titleView.text = item.title;
		if(item.artist != nil) {
			cell.artistView.text = item.artist?.name;
		}
		
		cell.titlesStackView.removeArrangedSubview(cell.albumPlaylistView);
		cell.albumPlaylistView.removeFromSuperview();
		
		if(indexPath.item > 0) {
			let topBorder: CALayer = CALayer();
			// beware of retina displays! in iPhone X for example, height: 0.3 won't work but it works properly in iPad Pro
			// it has to do with scaling.
			topBorder.frame = CGRect(x: 0.0, y: -7.5, width: cell.bounds.width, height: 0.5);
			topBorder.backgroundColor = UIColor.lightGray.cgColor;
			cell.layer.addSublayer(topBorder);
		} else {
			// this fixes an error where a topBorder from older layouts might still exist for the first item
			if(cell.layer.sublayers?.last?.backgroundColor == UIColor.lightGray.cgColor) {
				cell.layer.sublayers?.last?.backgroundColor = UIColor.clear.cgColor;
			}
		}
		
		return cell;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = self.dataList[indexPath.item];
		
		self.navigationDelegate?.navigateToVCFor(album: item);
	}
	
	func sendPlayBroadcastNotification(playableList: [PlayableItem], currentPlayableItemIndex: Int) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : playableList, "currentPlayableItemIndex": currentPlayableItemIndex]);
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.bounds.width - 30, height: 80);
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
