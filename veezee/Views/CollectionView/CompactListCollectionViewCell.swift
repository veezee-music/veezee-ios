//
//  CompactListCollectionViewCell.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 10/18/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift
import Kingfisher

class CompactListCollectionViewCell: UICollectionViewCell {
	static let ID = "CompactListCollectionViewCell";
	
	weak var navigationDelegate: NavigationControllerDelegate?;
	
	var dataList = [Album]();
	
	static let insetSize: CGFloat = 15;
	
	lazy var cellWidth: CGFloat = self.bounds.width - (CompactListCollectionViewCell.insetSize * 2);
	static let cellHeight: CGFloat = 40;
	
	lazy var collectionViewFlowLayout: SnappingCollectionViewFlowLayout = {
		let collectionViewFlowLayout = SnappingCollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = HorizontalSmallDoubleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = HorizontalSmallDoubleRowCollectionViewCell.insetSize;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: HorizontalSmallDoubleRowCollectionViewCell.insetSize, left: HorizontalSmallDoubleRowCollectionViewCell.insetSize, bottom: HorizontalSmallDoubleRowCollectionViewCell.insetSize, right: HorizontalSmallDoubleRowCollectionViewCell.insetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(AlbumCompactViewCell.self, forCellWithReuseIdentifier: AlbumCompactViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.translatesAutoresizingMaskIntoConstraints = false;
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
		
		return collectionView;
	}();
	
	lazy var collectionViewTitleView: UILabel = {
		let latestMusicsLabel = UILabel();
		latestMusicsLabel.translatesAutoresizingMaskIntoConstraints = false;
		latestMusicsLabel.textColor = Constants.PRIMARY_TEXT_COLOR;
		//let boldFont = UIFont.preferredFont(forTextStyle: .largeTitle);
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		latestMusicsLabel.font = boldFont.withSize(20);
		
		return latestMusicsLabel;
	}();
	
//	lazy var seeAllButton: UIButton = {
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
		self.collectionViewTitleView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(0).offset(HorizontalSmallDoubleRowCollectionViewCell.insetSize - 5)
			make.left.equalTo(0).offset(HorizontalSmallDoubleRowCollectionViewCell.insetSize)
			make.height.equalTo(25)
		});
		
//		self.addSubview(self.seeAllButton);
//		self.seeAllButton.snp.makeConstraints({(make) -> Void in
//			make.top.equalTo(0).offset(HorizontalSmallDoubleRowCollectionViewCell.insetSize - 5)
//			make.right.equalTo(0).inset(HorizontalSmallDoubleRowCollectionViewCell.insetSize)
//			make.height.equalTo(25)
//		});
		
		self.addSubview(self.headingsDividerView);
		self.headingsDividerView.snp.makeConstraints({(make) -> Void in
			make.height.equalTo(1)
			make.width.equalToSuperview()
			make.top.equalTo(self.collectionViewTitleView.snp.bottom)
		});
		
		self.addSubview(self.collectionView);
		self.collectionView.snp.makeConstraints({(make) -> Void in
			make.bottom.equalTo(self.snp.bottom)
			make.top.equalTo(self.headingsDividerView.snp.bottom)
			make.left.right.equalTo(0)
		});
	}
	
	@objc
	private func seeAllButtonClicked() {
		if(self.dataList.first?.artist == nil) {
			self.navigationDelegate?.navigateToVCFor(playLists: self.dataList);
		} else {
			self.navigationDelegate?.navigateToVCFor(albumsList: self.dataList);
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension CompactListCollectionViewCell: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCompactViewCell.ID, for: indexPath) as! AlbumCompactViewCell;
		
		let item = self.dataList[indexPath.item];
		
		cell.titleView.text = item.title;
		cell.trackCountView.text = String(item.tracks?.count ?? 0) + " tracks";
		
		return cell;
	}
	
}

extension CompactListCollectionViewCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// it's probably a playlist (doesn't have artist), so reduce the height
		if(self.dataList.first?.artist == nil) {
//			let newCellWidth = HorizontalSmallDoubleRowCollectionViewCell.cellWidth - 20;
//			self.collectionView.snp.updateConstraints({(make) -> Void in
//				make.height.equalTo(HorizontalSmallDoubleRowCollectionViewCell.cellWidth * 2 + self.musicSmallCardInsetSize * 3);
//			});
		}
		
		return self.dataList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = self.dataList[indexPath.item];
		
		self.navigationDelegate?.navigateToVCFor(album: item);
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.cellWidth, height: CompactListCollectionViewCell.cellHeight);
	}
	
}
