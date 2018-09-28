//
//  HorizontalTinyTripleRowCollectionViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift
import Kingfisher

class HorizontalTinyTripleRowCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
	static let ID = "HorizontalTinyTripleRowCollectionViewCell";
	
	weak var navigationDelegate: NavigationControllerDelegate?;
	
	var dataList = [Track]();
	var playableList = [PlayableItem]();
	
	static let insetSize: CGFloat = 15;
	
	static let cellHeight: CGFloat = 50;
	static let cellWidth = HorizontalTinyTripleRowCollectionViewCell.cellHeight + 50;
	
	lazy var collectionViewFlowLayout : SnappingCollectionViewFlowLayout = {
		let collectionViewFlowLayout = SnappingCollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .horizontal;
		collectionViewFlowLayout.minimumLineSpacing = HorizontalTinyTripleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = HorizontalTinyTripleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: HorizontalTinyTripleRowCollectionViewCell.insetSize, left: HorizontalTinyTripleRowCollectionViewCell.insetSize, bottom: HorizontalTinyTripleRowCollectionViewCell.insetSize, right: HorizontalTinyTripleRowCollectionViewCell.insetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(MusicTinyViewCell.self, forCellWithReuseIdentifier: MusicTinyViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.translatesAutoresizingMaskIntoConstraints = false;
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
	
	lazy var seeAllButton: UIButton = {
		let seeAllButton = UIButton();
		seeAllButton.titleLabel?.font = seeAllButton.titleLabel?.font.withSize(15);
		seeAllButton.setTitle("See All", for: .normal);
		seeAllButton.setTitleColor(Constants.PRIMARY_TEXT_COLOR, for: .normal);
		seeAllButton.setTitleColor(Constants.PRIMARY_TEXT_COLOR.withAlphaComponent(0.6), for: .highlighted);
		seeAllButton.addTarget(self, action: #selector(self.seeAllButtonClicked), for: .touchUpInside);
		
		return seeAllButton;
	}();
	
	lazy var headingsDividerView : UIView = {
		let headingsDivider = UIView();
		
		return headingsDivider;
	}();
	
	var trackLongPressEnded = false;
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.addSubview(self.collectionViewTitleView);
		
		self.collectionViewTitleView.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(0).offset(HorizontalTinyTripleRowCollectionViewCell.insetSize - 5)
			make.left.equalTo(0).offset(HorizontalTinyTripleRowCollectionViewCell.insetSize)
			make.height.equalTo(25)
		});
		
		self.addSubview(self.seeAllButton);
		
		self.seeAllButton.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(0).offset(HorizontalTinyTripleRowCollectionViewCell.insetSize - 5)
			make.right.equalTo(0).inset(HorizontalTinyTripleRowCollectionViewCell.insetSize)
			make.height.equalTo(25)
		});
		
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
		
		let cellLongPressGestureRecognizer = UILongPressGestureRecognizer { gesture, state in
			if (gesture.state == UIGestureRecognizerState.ended) {
				self.trackLongPressEnded = false;
				return;
			}
			
			if(self.trackLongPressEnded) {
				return;
			}
			
			let gestureRecognizerLocation = gesture.location(in: self.collectionView);
			if let indexPath = self.collectionView.indexPathForItem(at: gestureRecognizerLocation) {
				let item = self.dataList[indexPath.item];
				NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.trackLongPressedBroadcastNotificationKey), object: self, userInfo: ["track" : item]);
			}
			
			self.trackLongPressEnded = true;
		};
		cellLongPressGestureRecognizer.minimumPressDuration = 0.5;
		cellLongPressGestureRecognizer.delegate = self;
		cellLongPressGestureRecognizer.delaysTouchesBegan = true;
		self.collectionView.addGestureRecognizer(cellLongPressGestureRecognizer);
	}
	
	@objc
	private func seeAllButtonClicked() {
		self.navigationDelegate?.navigateToVCFor(tracksList: self.dataList);
	}
	
	private func sendPlayBroadcastNotification(playableList: [PlayableItem], currentPlayableItemIndex: Int) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : playableList, "currentPlayableItemIndex": currentPlayableItemIndex]);
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HorizontalTinyTripleRowCollectionViewCell: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicTinyViewCell.ID, for: indexPath) as! MusicTinyViewCell;
		
		let item = self.dataList[indexPath.item];
		
		if(item.image != nil && item.image != "") {
			cell.artworkImageView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: item.image!), placeholder: UIImage(named: "artwork"));
		} else {
			cell.artworkImageView.image = UIImage(named: "artwork");
		}
		
		cell.titleView.text = item.title;
		cell.artistView.text = item.album?.artist?.name;
		
		return cell;
	}
	
}

extension HorizontalTinyTripleRowCollectionViewCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: HorizontalTinyTripleRowCollectionViewCell.cellWidth * 2.5, height: HorizontalTinyTripleRowCollectionViewCell.cellHeight);
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// the large track image seems to kinda delay this methods execution
		//	let currentItem = self.dataList[indexPath.item];
		
		if(self.playableList.count <= 0) {
			self.playableList = generatePlayableListFromTracksList(list: self.dataList);
			self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: indexPath.item);
		} else {
			// playable list already initialized
			self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: indexPath.item);
		}
	}
	
}
