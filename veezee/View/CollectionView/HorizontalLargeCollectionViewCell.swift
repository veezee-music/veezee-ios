//
//  HorizontalLargeCollectionViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

class HorizontalLargeCollectionViewCell: UICollectionViewCell {
	static let ID = "HorizontalLargeCollectionViewCell";
	
	weak var navigationDelegate: NavigationControllerDelegate?;
	
	var dataList = [Header]();
	
	static let insetSize: CGFloat = 15;
	
	lazy var headerLargeCardSideSizeHorizontal: CGFloat = 600;
	
	lazy var collectionViewFlowLayout: SnappingCollectionViewFlowLayout = {
		let collectionViewFlowLayout = SnappingCollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .horizontal;
		collectionViewFlowLayout.minimumLineSpacing = HorizontalLargeCollectionViewCell.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = HorizontalLargeCollectionViewCell.insetSize;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: HorizontalLargeCollectionViewCell.insetSize, left: HorizontalLargeCollectionViewCell.insetSize, bottom: HorizontalLargeCollectionViewCell.insetSize, right: HorizontalLargeCollectionViewCell.insetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(HeaderViewCell.self, forCellWithReuseIdentifier: HeaderViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
		
		return collectionView;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		let device = Device();
		let magicPercentage: CGFloat = device.isPad ? 75.0 : 83.0;
		self.headerLargeCardSideSizeHorizontal = self.bounds.width * magicPercentage / 100;
		
		self.setupUI();
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension HorizontalLargeCollectionViewCell: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderViewCell.ID, for: indexPath) as! HeaderViewCell;
		
		let item = self.dataList[indexPath.item];
		
		if(item.image != nil && item.image != "") {
			cell.artworkImageView.kf.setImage(with: URL(string: (item.image)!), placeholder: UIImage(named: "artwork"));
		}
		
		cell.descriptionView.text = item.type?.uppercased();
		cell.titleView.text = item.title;
		cell.artistView.text = item.artist?.name;
		
		return cell;
	}
	
}

extension HorizontalLargeCollectionViewCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.dataList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = self.dataList[indexPath.item];
		
		self.navigationDelegate?.navigateToVCFor(album: item.album!);
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.headerLargeCardSideSizeHorizontal, height: self.frame.height - 2 * HorizontalLargeCollectionViewCell.insetSize);
	}
	
}

extension HorizontalLargeCollectionViewCell {
	
	func setupUI() {
		self.addSubviewOnce(self.collectionView);
		self.collectionView.snp.remakeConstraints({(make) -> Void in
			make.top.bottom.equalTo(0)
			make.left.right.equalTo(0)
		});
		self.collectionView.collectionViewLayout.invalidateLayout();
	}
	
}
