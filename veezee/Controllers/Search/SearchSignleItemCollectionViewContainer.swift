//
//  SignleItemCollectionViewContainer.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 7/8/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit

protocol SearchQueryListDelegate: AnyObject {
	func querySelected(query: String);
}

class SearchSignleItemCollectionViewContainer: UIView {
	
	weak var delegate: SearchQueryListDelegate?;
	
	lazy var collectionView: UICollectionView = {
		let collectionViewFlowLayout = SingleItemWithSeparatorFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = 1;
		collectionViewFlowLayout.register(SeparatorView.self, forDecorationViewOfKind: SeparatorView.ID);
		collectionViewFlowLayout.sectionInset = .zero;
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(SingleTitleCollectionViewCell.self, forCellWithReuseIdentifier: SingleTitleCollectionViewCell.ID);
		collectionView.register(CollectionCustomHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionCustomHeader.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}();
	
	var headersList = [String]();
	var itemsList = [String]();
	var numberOfItemsInSection = 0;
	
	override init(frame: CGRect) {
		super.init(frame: .zero);
		
		self.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.addSubview(self.collectionView);
		self.collectionView.snp.remakeConstraints ({ (make) in
			make.top.equalTo(0)//lessThanOrEqualTo(self.titleView.snp.bottom).offset(20)
			make.bottom.equalTo(0)
			make.left.right.equalTo(0)
		});
		self.collectionView.layoutIfNeeded();
	}
	
	func setData(dataList: [SearchQueryList]) {
		for data in dataList {
			self.headersList.append(data.title ?? "");
			for item in data.queries {
				self.itemsList.append(item);
				
				if(self.numberOfItemsInSection == 0) {
					self.numberOfItemsInSection = data.queries.count;
				}
			}
		}
		self.collectionView.reloadData();
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

extension SearchSignleItemCollectionViewContainer: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.itemsList[(indexPath.section * self.numberOfItemsInSection) + indexPath.item];
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleTitleCollectionViewCell.ID, for: indexPath) as! SingleTitleCollectionViewCell;
		cell.titleView.text = item;
		
		return cell;
	}
	
}

extension SearchSignleItemCollectionViewContainer: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let item = self.headersList[indexPath.section];
		
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionCustomHeader.ID, for: indexPath) as! CollectionCustomHeader;
		
		view.titleView.text = item;
		
		return view;
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 50);
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.headersList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.numberOfItemsInSection;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = self.itemsList[(indexPath.section * self.numberOfItemsInSection) + indexPath.item];
		
		self.delegate?.querySelected(query: item);
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.bounds.width, height: 50);
	}
}

private class CollectionCustomHeader: UICollectionReusableView {
	
	static let ID = "CollectionCustomHeader";
	
	lazy var titleView: UILabel = {
		let titleView = UILabel();
		titleView.textColor = Constants.PRIMARY_TEXT_COLOR;
		titleView.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold);
		
		return titleView;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.addSubview(titleView);
		titleView.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
			make.left.equalTo(10)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented");
	}
	
}


private class SingleTitleCollectionViewCell: BaseCollectionViewCell {
	
	static let ID = "SingleTitleCollectionViewCell";
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.ACCENT_COLOR;
		lb.font = lb.font.withSize(18);
		
		return lb;
	}();
	
	override var isHighlighted: Bool {
		didSet {
			self.backgroundColor = self.isHighlighted ? Constants.ACCENT_COLOR : Constants.PRIMARY_COLOR;
			self.titleView.textColor = self.isHighlighted ? UIColor.white : Constants.ACCENT_COLOR;
		}
	}
	
	override func setupUI() {
		super.setupUI();
		
		self.addSubview(self.titleView);
		self.titleView.snp.remakeConstraints({(make) -> Void in
			make.centerY.equalToSuperview()
			make.right.equalTo(0)
			make.left.equalTo(10)
		});
	}
	
}

class SingleItemWithSeparatorFlowLayout: UICollectionViewFlowLayout {
	
	var skipFirstItem: Bool = false;
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? [];
		let lineWidth = self.minimumLineSpacing;
		
		var decorationAttributes: [UICollectionViewLayoutAttributes] = [];
		
		for layoutAttribute in layoutAttributes where skipFirstItem ? (layoutAttribute.indexPath.item > 0) : true {
			// skip the first item in each section
			if(layoutAttribute.indexPath.item == 0) {
				continue;
			}
			
			let separatorAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: SeparatorView.ID, with: layoutAttribute.indexPath);
			let cellFrame = layoutAttribute.frame;
			separatorAttribute.frame = CGRect(x: cellFrame.origin.x, y: cellFrame.origin.y, width: cellFrame.size.width, height: lineWidth);
			separatorAttribute.zIndex = Int.max;
			decorationAttributes.append(separatorAttribute);
		}
		
		return layoutAttributes + decorationAttributes;
	}
	
}

private class SeparatorView: UICollectionReusableView {
	
	static let ID = "SeparatorView";
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3);
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		self.frame = layoutAttributes.frame;
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented");
	}
}
