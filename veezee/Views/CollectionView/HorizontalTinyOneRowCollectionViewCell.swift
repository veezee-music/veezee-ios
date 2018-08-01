//
//  HorizontalTinyOneRowCollectionViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 veezee. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift
import Kingfisher

class HorizontalTinyOneRowCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
	static let ID = "HorizontalTinyOneRowCollectionViewCell";
	
	var dataList = [Genre]();
	
	static let insetSize: CGFloat = 15;
	
	static let cellWidth: CGFloat = 100;
	static let cellHeight = HorizontalTinyTripleRowCollectionViewCell.cellWidth + 2 * HorizontalTinyTripleRowCollectionViewCell.insetSize;
	
	lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .horizontal;
		collectionViewFlowLayout.minimumLineSpacing = HorizontalTinyTripleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = HorizontalTinyTripleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: HorizontalTinyTripleRowCollectionViewCell.insetSize, left: HorizontalTinyTripleRowCollectionViewCell.insetSize, bottom: HorizontalTinyTripleRowCollectionViewCell.insetSize, right: HorizontalTinyTripleRowCollectionViewCell.insetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(GenreTinyViewCell.self, forCellWithReuseIdentifier: GenreTinyViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
		
		return collectionView;
	}();
	
	lazy var collectionViewTitleView: UILabel = {
		let latestMusicsLabel = UILabel()
		latestMusicsLabel.translatesAutoresizingMaskIntoConstraints = false;
		latestMusicsLabel.textColor = Constants.PRIMARY_TEXT_COLOR;
		//let boldFont = UIFont.preferredFont(forTextStyle: .largeTitle);
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		latestMusicsLabel.font = boldFont.withSize(20);
		
		return latestMusicsLabel;
	}();
	
//	lazy var seeAllButton : UIButton = {
//		let seeAllButton = UIButton();
//		seeAllButton.titleLabel?.font = seeAllButton.titleLabel?.font.withSize(15);
//		seeAllButton.setTitle("See All", for: .normal);
//		seeAllButton.setTitleColor(Constants.PRIMARY_TEXT_COLOR, for: .normal);
//		seeAllButton.setTitleColor(Constants.PRIMARY_TEXT_COLOR.withAlphaComponent(0.6), for: .highlighted);
//		seeAllButton.addTarget(self, action: #selector(self.seeAllButtonClicked), for: .touchUpInside);
//
//		return seeAllButton;
//	}();
	
	lazy var headingsDividerView: UIView = {
		let headingsDivider = UIView();
		
		return headingsDivider;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.addSubview(self.collectionViewTitleView);
		
		self.collectionViewTitleView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(0).offset(HorizontalTinyTripleRowCollectionViewCell.insetSize - 5)
			make.left.equalTo(0).offset(HorizontalTinyTripleRowCollectionViewCell.insetSize)
			make.height.equalTo(25)
		});
		
//		self.addSubview(self.seeAllButton);
//
//		self.seeAllButton.snp.makeConstraints({(make) -> Void in
//			make.top.equalTo(0).offset(HorizontalTinyTripleRowCollectionViewCell.insetSize - 5)
//			make.right.equalTo(0).inset(HorizontalTinyTripleRowCollectionViewCell.insetSize)
//			make.height.equalTo(25)
//		});
		
		self.addSubview(self.headingsDividerView);
		
		self.headingsDividerView.snp.remakeConstraints({(make) -> Void in
			make.height.equalTo(1)
			make.width.equalToSuperview()
			make.top.equalTo(self.collectionViewTitleView.snp.bottom)
		});
		
		self.addSubview(self.collectionView);
		self.collectionView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.headingsDividerView.snp.bottom)
			make.bottom.equalTo(self.snp.bottom)
			make.left.right.equalTo(0)
		});
		
		let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleCellLongPress(gestureRecognizer:)));
		lpgr.minimumPressDuration = 0.5;
		lpgr.delegate = self;
		lpgr.delaysTouchesBegan = true;
		self.collectionView.addGestureRecognizer(lpgr);
	}
	
	var longPressEnded = false;
	@objc
	func handleCellLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
		if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
			self.longPressEnded = false;
			return;
		}
		
		if(self.longPressEnded) {
			// no go, too soon
			return;
		}
		
		let gestureRecognizer = gestureRecognizer.location(in: self.collectionView);
		
		if let indexPath = self.collectionView.indexPathForItem(at: gestureRecognizer) {
			// get the cell at indexPath (the one you long pressed)
			// let cell = self.collectionView.cellForItem(at: indexPath) as! MusicTinyViewCell;
			let item = self.dataList[indexPath.item];
			NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.trackLongPressedBroadcastNotificationKey), object: self, userInfo: ["track" : item]);
		}
		
		self.longPressEnded = true;
	}
	
	private func sendPlayBroadcastNotification(playableList: [PlayableItem], currentPlayableItemIndex: Int) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : playableList, "currentPlayableItemIndex": currentPlayableItemIndex]);
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HorizontalTinyOneRowCollectionViewCell: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreTinyViewCell.ID, for: indexPath) as! GenreTinyViewCell;

		let item = self.dataList[indexPath.item];
		
		if(item.image != nil && item.image != "") {
			cell.imageView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: item.image!), placeholder: UIImage(named: "artwork"));
		}
		
		cell.titleView.text = item.title;
		
		return cell;
	}
	
}

extension HorizontalTinyOneRowCollectionViewCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: HorizontalTinyOneRowCollectionViewCell.cellWidth, height: HorizontalTinyOneRowCollectionViewCell.cellHeight);
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// the large track image seems to kinda delay this methods execution
		//	let currentItem = self.dataList[indexPath.item];
		
//		if(self.playableList.count <= 0) {
//			DispatchQueue.global(qos: .background).async {
//				// build the PlayableList, used by audio player
//				self.playableList = generatePlayableListFromTracksList(list: self.dataList);
//
//				DispatchQueue.main.async {
//					self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: indexPath.item);
//				}
//			}
//		} else {
//			// playable list already initialized
//			self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: indexPath.item);
//		}
	}
	
}
