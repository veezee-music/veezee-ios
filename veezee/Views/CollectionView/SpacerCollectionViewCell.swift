//
//  SpacerCollectionViewCell.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

class SpacerCollectionViewCell : UICollectionViewCell {
	static let ID = "SpacerCollectionViewCell";
	
	lazy var collectionViewFlowLayout : UICollectionViewFlowLayout = {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .horizontal;
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellIdentifier");
		collectionView.translatesAutoresizingMaskIntoConstraints = false;
		
		return collectionView;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.addSubview(self.collectionView);
		self.collectionView.snp.remakeConstraints({(make) -> Void in
			make.width.equalToSuperview();
			make.height.equalTo(10);
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
