//
//  AccountViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/28/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit
import SnapKit

class AccountViewController: _BasePageViewController, UICollectionViewDataSource {
	
	lazy var navigationBarHeight = self.navigationController?.navigationBar.frame.size.height;
	lazy var tabBarHeight = self.tabBarController?.tabBar.frame.size.height;
	
	lazy var nameView: UILabel = {
		let nameView = UILabel();
		nameView.text = self.keychain.get("name") ?? "";
		nameView.textColor = Constants.PRIMARY_TEXT_COLOR;
		nameView.font = UIFont.systemFont(ofSize: self.device.isPad ? 30 : 23, weight: UIFont.Weight.black);
		
		return nameView;
	}();
	
	lazy var emailView: UILabel = {
		let emailView = UILabel();
		emailView.text = self.keychain.get("email");
		emailView.textColor = Constants.PRIMARY_TEXT_COLOR.withAlphaComponent(0.8);
		topSection.addSubviewOnce(emailView);
		emailView.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular);
		
		return emailView;
	}();
	
	let topSection = UIView();
	let bottomSection = UIView();
	let topSectionInnerContainer = UIView();
	
	lazy var carouselSize: CGSize = {
		var width: CGFloat = 0;
		
		if(self.device.isPad) {
			width = self.bottomSection.frame.width / 3;
		} else {
			width = self.bottomSection.frame.width / 2.5;
		}
		
		// 25 is added for label
		let height = width + 25;
		
		return CGSize(width: width, height: height);
	}();
	
	lazy var collectionViewFlowLayout: UPCarouselFlowLayout = {
		let collectionViewFlowLayout = UPCarouselFlowLayout();
		collectionViewFlowLayout.scrollDirection = .horizontal;
		collectionViewFlowLayout.sideItemScale = 0.8;
		collectionViewFlowLayout.itemSize = self.carouselSize;
		collectionViewFlowLayout.spacingMode = .fixed(spacing: self.device.isPad ? 60 : 30);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(MusicCarouselViewCell.self, forCellWithReuseIdentifier: MusicCarouselViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		collectionView.translatesAutoresizingMaskIntoConstraints = false;
		
		return collectionView;
	}();
	
	var items = [Track]();
	
	var currentItemIndex: Int = 0 {
		didSet {
			if(self.currentItemIndex < 0) {
				self.currentItemIndex = 0;
			}
			if(self.currentItemIndex >= self.items.count - 1) {
				self.currentItemIndex = self.currentItemIndex - 1;
			}
			print(self.currentItemIndex)
//			let item = self.items[self.currentItemIndex]
//			item.ti
//			self.detailLabel.text = character.movie.uppercased()
		}
	}
	
	var pageSize: CGSize {
		let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
		
		
		var widthAndHeight: CGFloat = 0;
		
		if(self.device.isPad) {
			widthAndHeight = self.bottomSection.frame.width / 3
		} else {
			widthAndHeight = self.bottomSection.frame.width / 2
		}
		
		let width = widthAndHeight;
		// 25 is added for label
		let height = widthAndHeight + 25;
		
		
		
		
		var pageSize = CGSize(width: width, height: height)
		if layout.scrollDirection == .horizontal {
			pageSize.width += layout.minimumLineSpacing
		} else {
			pageSize.height += layout.minimumLineSpacing
		}
		return pageSize
	}
	
	override func shouldLeaveNavigationTitleUnchanged() -> Bool {
		return true;
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.setupUI();
		
		self.loadRecentlyPlayedTracks();
		
		self.initializeBottomPlayer();
	}
	
	func setupUI() {
		// top section
		self.view.addSubviewOnce(self.topSection);
		self.topSection.snp.remakeConstraints ({ (make) in
			make.top.equalTo(BottomPlayer.Height / 2)
			make.left.right.equalTo(0)
			make.height.equalToSuperview().dividedBy(2).inset(BottomPlayer.Height / 2)
		});
		self.topSection.layoutIfNeeded();
		
		// top section inner container
		self.topSectionInnerContainer.addSubviewOnce(self.nameView);
		self.nameView.snp.remakeConstraints ({(make) in
			make.top.equalTo(0)
			make.centerX.equalToSuperview()
		});
		self.nameView.layoutIfNeeded();
		
		self.topSectionInnerContainer.addSubviewOnce(self.emailView);
		self.emailView.snp.remakeConstraints ({(make) in
			make.top.equalTo(self.nameView.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
		});
		self.emailView.layoutIfNeeded();
		
		let changeEmailButton = LGButton();
		changeEmailButton.titleString = "Change email or password";
		changeEmailButton.titleFontSize = 17;
		changeEmailButton.titleColor = Constants.PRIMARY_TEXT_COLOR;
		changeEmailButton.cornersRadius = 4;
		changeEmailButton.bordersWidth = 1;
		changeEmailButton.bordersColor = .red;
		changeEmailButton.bgColor = Constants.PRIMARY_COLOR;
		self.topSectionInnerContainer.addSubviewOnce(changeEmailButton);
		changeEmailButton.snp.remakeConstraints ({(make) in
			make.top.equalTo(emailView.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
			make.width.greaterThanOrEqualTo(0)
		});
		changeEmailButton.layoutIfNeeded();
		
		self.topSection.addSubviewOnce(topSectionInnerContainer);
		let topSectionInnerContainerHeight = self.nameView.frame.height + self.emailView.frame.height + changeEmailButton.frame.height + 20 + 20;
		self.topSectionInnerContainer.snp.remakeConstraints ({ (make) in
			make.centerY.equalTo(topSection)
			make.left.right.equalTo(0)
			make.height.equalTo(topSectionInnerContainerHeight)
		});
		self.topSectionInnerContainer.layoutIfNeeded();
		
		// bottom section
		self.view.addSubviewOnce(self.bottomSection);
		self.bottomSection.snp.remakeConstraints ({ (make) in
			make.top.equalTo(topSection.snp.bottom)
			make.left.right.equalTo(0)
			make.height.equalTo(topSection.frame.height - BottomPlayer.Height)
		});
		self.bottomSection.layoutIfNeeded();
		
		self.bottomSection.addSubviewOnce(self.collectionView);
		self.collectionView.snp.remakeConstraints({(make) -> Void in
			make.left.right.equalTo(0)
			make.bottom.equalTo(0)
			make.height.equalTo(self.bottomSection.frame.height)
		});
		self.collectionView.collectionViewLayout.invalidateLayout();
	}
	
	func loadRecentlyPlayedTracks() {
		for n in 0...5 {
			let g = Track();
			self.items.append(g)
		}
	}
	
	override func addNavigationButtons() {
		let settingsBtn = UIBarButtonItem();
		settingsBtn.target = self;
		settingsBtn.action = #selector(self.logOutButtonPressed(_:));
		settingsBtn.title = "Log out";
		self.navigationItem.rightBarButtonItem = settingsBtn;
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil);
	}
	
	@objc
	func logOutButtonPressed(_ sender: AnyObject) {
		self.audioPlayer.stop();
		self.keychain.clear();
		UIView.transition(with: (UIApplication.shared.delegate?.window!)!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
			UIApplication.shared.isStatusBarHidden = false;
			let vc = SplashScreenViewController();
			UIApplication.shared.delegate?.window!?.rootViewController = vc;
		});
	}
	
}

extension AccountViewController : UICollectionViewDelegateFlowLayout {
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout;
		let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height;
		let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y;
		let tmpIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1);
		currentItemIndex = tmpIndex;
		
//		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCarouselViewCell.ID, for: IndexPath(row: self.currentItemIndex, section: 0));
		print(currentItemIndex)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		let item = self.homePageItems[indexPath.item];
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCarouselViewCell.ID, for: indexPath) as! MusicCarouselViewCell;
		cell.titleView.text = "Track title";
		cell.artworkImageView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: "https://veezee.cloud/content/images/5aedd5a0cd6e51525536160.jpg"), placeholder: UIImage(named: "artwork"));

		return cell;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		let item = self.homePageItems[indexPath.item];

		return self.carouselSize;
	}
}




class MusicCarouselViewCell : UICollectionViewCell {
	static let ID = "MusicCarouselViewCell";
	
	lazy var albumArtShadowContainer: UIView = {
		let view = UIView();
		view.layer.shadowRadius = self.device.isPad ? 30 : 15;
		view.backgroundColor = Constants.PRIMARY_COLOR
		view.layer.shadowOpacity = 0.6;
		view.layer.shadowColor = Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR ? UIColor.gray.cgColor : UIColor.white.cgColor;
		
		return view;
	}();
	
	lazy var artworkImageView: UIImageView = {
		let iv = UIImageView(frame: .zero);
		if(Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR) {
			iv.borderWidth = 0.3;
			iv.borderColor = Constants.IMAGES_BORDER_COLOR;
		}
		iv.layer.cornerRadius = 8;
		iv.contentMode = .scaleAspectFit;
		iv.clipsToBounds = true;
		iv.image = UIImage(named: "artwork");
		
		return iv;
	}();
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		lb.textAlignment = .center;
		
		return lb;
	}();
	
	let device = Device();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		self.translatesAutoresizingMaskIntoConstraints = false;
		
		self.addSubview(self.albumArtShadowContainer);
		self.addSubview(self.artworkImageView);
		
		self.artworkImageView.snp.makeConstraints({(make) -> Void in
			make.width.height.equalTo(self.frame.width);
			make.left.right.equalTo(0);
			make.top.equalTo(0);
		});
		self.artworkImageView.layoutIfNeeded();
		
		self.albumArtShadowContainer.snp.makeConstraints({(make) -> Void in
			make.width.height.equalTo(self.artworkImageView).inset(10)
			make.centerX.centerY.equalTo(self.artworkImageView)
		});
		
		self.addSubview(self.titleView);
		self.titleView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(self.artworkImageView.snp.bottom).offset(16);
			make.width.equalToSuperview();
			make.height.equalTo(20)
			make.left.right.equalTo(0);
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UICollectionView {
	func scrollToNextItem() {
		let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
		self.moveToFrame(contentOffset: contentOffset)
	}
	
	func scrollToPreviousItem() {
		let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
		self.moveToFrame(contentOffset: contentOffset)
	}
	
	func moveToFrame(contentOffset : CGFloat) {
		let frame: CGRect = CGRect(x: contentOffset, y: self.contentOffset.y , width: self.frame.width, height: self.frame.height)
		self.scrollRectToVisible(frame, animated: true)
	}
}
