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
	
	fileprivate var orientation: UIDeviceOrientation {
		return UIDevice.current.orientation
	}
	
	lazy var navigationBarHeight = self.navigationController?.navigationBar.frame.size.height;
	lazy var tabBarHeight = self.tabBarController?.tabBar.frame.size.height;
	
	lazy var nameView: UILabel = {
		let nameView = UILabel();
		nameView.text = self.keychain.get("name") ?? "";
		nameView.textColor = Constants.PRIMARY_TEXT_COLOR;
		nameView.font = UIFont.systemFont(ofSize: self.device.isPad ? 30 : 23, weight: UIFont.Weight.black);
		
		return nameView;
	}();
	
	lazy var premiumUntilLabel: UILabel = {
		let premiumUntilLabel = UILabel();
		premiumUntilLabel.text = "Premium days left:"
		premiumUntilLabel.textColor = Constants.PRIMARY_TEXT_COLOR;
		premiumUntilLabel.font = UIFont.systemFont(ofSize: self.device.isPad ? 18 : 15, weight: UIFont.Weight.light);
		
		return premiumUntilLabel;
	}();
	
	lazy var daysRemainingView: UILabel = {
		let daysRemainingView = UILabel();
		daysRemainingView.text = "Less than a day";
		daysRemainingView.textColor = Constants.PRIMARY_TEXT_COLOR;
		daysRemainingView.font = UIFont.systemFont(ofSize: self.device.isPad ? 18 : 15, weight: UIFont.Weight.black);
		
		return daysRemainingView;
	}();
	
//	lazy var daysRemainingView: UILabel = {
//		let daysRemainingView = UILabel();
//		daysRemainingView.textColor = Constants.PRIMARY_TEXT_COLOR;
//		daysRemainingView.text = "24"//"∞";
//		daysRemainingView.font = UIFont.systemFont(ofSize: self.device.isPad ? 90 : 50, weight: UIFont.Weight.heavy);
//
//		return daysRemainingView;
//	}();
	
	lazy var collectionViewFlowLayout: UPCarouselFlowLayout = {
		let collectionViewFlowLayout = UPCarouselFlowLayout();
		collectionViewFlowLayout.scrollDirection = .horizontal;
		collectionViewFlowLayout.spacingMode = .fixed(spacing: 50)
//		collectionViewFlowLayout.minimumLineSpacing = self.musicSmallCardInsetSize;
//		collectionViewFlowLayout.minimumInteritemSpacing = self.musicSmallCardInsetSize;
//		collectionViewFlowLayout.sectionInset = .zero;
		//collectionViewFlowLayout.estimatedItemSize = CGSize(width: view.bounds.width, height: 600.0);
		
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
		
		self.view.addSubview(self.nameView);
		self.nameView.snp.makeConstraints ({(make) in
			make.top.equalTo(0)
			make.centerX.equalToSuperview()
		});
		self.nameView.layoutIfNeeded();
		
//		self.view.addSubview(self.premiumUntilLabel);
//		self.premiumUntilLabel.snp.makeConstraints ({ (make) in
//			make.top.equalTo(self.nameView.snp.bottom).offset(10)
//			make.centerX.equalToSuperview()
//		});
		
		let leftContainer = UIView();
		self.view.addSubview(leftContainer);
		leftContainer.snp.makeConstraints ({ (make) in
			make.top.equalTo(self.nameView.snp.bottom).offset(10)
			make.left.equalTo(10)
			make.height.equalTo(40)
			make.width.equalTo(self.view.frame.width / 2)
		});
		
		let rightContainer = UIView();
		self.view.addSubview(rightContainer);
		rightContainer.snp.makeConstraints ({ (make) in
			make.top.equalTo(self.nameView.snp.bottom).offset(10)
			make.right.equalTo(0).inset(10)
			make.height.equalTo(40)
			make.width.equalTo(self.view.frame.width / 2)
		});
		
//		leftContainer.addSubview(self.premiumUntilLabel);
//		self.premiumUntilLabel.snp.makeConstraints ({ (make) in
//			make.center.equalToSuperview()
//		});
//		
//		rightContainer.addSubview(self.daysRemainingView);
//		self.daysRemainingView.snp.makeConstraints ({ (make) in
//			make.center.equalToSuperview()
//		});
		
		let loginButton = LGButton();
		loginButton.titleString = "Log in";
		loginButton.titleFontSize = 18;
		loginButton.titleColor = .white;
		loginButton.cornersRadius = 4;
		loginButton.bgColor = Constants.ACCENT_COLOR;
		loginButton.shadowRadius = 4;
		loginButton.shadowOpacity = 2;
		loginButton.shadowOffset = CGSize(width: 0, height: 1);
		loginButton.shadowColor = Constants.ACCENT_COLOR;
		
		self.initializeBottomPlayer();
	}
	
	
	
	let bottomSection = UIView();
	
//	func bviewDidLoad() {
//		super.viewDidLoad();
//
//		for n in 0...10 {
//			let g = Track();
//			self.items.append(g)
//		}
//
//		self.currentItemIndex = 0
//
//		self.view.backgroundColor = Constants.PRIMARY_COLOR;
//
//		let availableHeight = self.view.frame.height;
//
//		let topSection = UIView();
//		self.view.addSubview(topSection);
//		topSection.snp.makeConstraints ({ (make) in
//			make.width.equalTo(self.view)
//			make.height.equalTo((availableHeight / 2) - navigationBarHeight! - (tabBarHeight! / 2))
//			make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
//		});
//		topSection.layoutIfNeeded();
//
//		var topSectionCenterContentHeight: CGFloat = 0;
//
//
//		topSection.addSubview(self.nameView);
//		self.nameView.snp.makeConstraints ({(make) in
//			make.centerX.equalTo(self.view)
//			make.width.lessThanOrEqualTo(self.view.bounds.width)
//		});
//		self.nameView.layoutIfNeeded();
//		topSectionCenterContentHeight += self.nameView.frame.height;
//
//
//		topSection.addSubview(self.premiumUntilLabel);
//		self.premiumUntilLabel.snp.makeConstraints ({(make) in
//			make.top.equalTo(nameView.snp.bottom).offset(20)
//			make.centerX.equalTo(self.view)
//			make.width.lessThanOrEqualTo(self.view.bounds.width)
//		});
//		self.premiumUntilLabel.layoutIfNeeded();
//		topSectionCenterContentHeight += (self.premiumUntilLabel.frame.height + 20);
//
//
//		topSection.addSubview(self.daysRemainingView);
//		self.daysRemainingView.snp.makeConstraints ({(make) in
//			make.top.equalTo(self.premiumUntilLabel.snp.bottom).offset(20)
//			make.centerX.equalTo(self.view)
//			make.width.lessThanOrEqualTo(self.view.bounds.width)
//		});
//		self.daysRemainingView.layoutIfNeeded();
//		topSectionCenterContentHeight += (self.daysRemainingView.frame.height + 20);
//
//		let hoursRemainingView = UILabel();
//		hoursRemainingView.textColor = Constants.PRIMARY_TEXT_COLOR;
//		hoursRemainingView.text = "24 Hours";//"∞";
//		hoursRemainingView.font = UIFont.systemFont(ofSize: self.device.isPad ? 20 : 16, weight: UIFont.Weight.heavy);
//		topSection.addSubview(hoursRemainingView);
//		hoursRemainingView.snp.makeConstraints ({(make) in
//			make.top.equalTo(daysRemainingView.snp.bottom).offset(5)
//			make.centerX.equalTo(self.view)
//			make.width.lessThanOrEqualTo(self.view.bounds.width)
//		});
//		hoursRemainingView.layoutIfNeeded();
//		topSectionCenterContentHeight += (hoursRemainingView.frame.height + 10);
//
//
//		let upgradeButtonView = UIButton();
//		upgradeButtonView.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold);
//		upgradeButtonView.setTitle("Upgrade", for: .normal);
//		let upgradeButtonViewTitleColor: UIColor = Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR ? Constants.ACCENT_COLOR : .yellow;
//		upgradeButtonView.setTitleColor(upgradeButtonViewTitleColor, for: .normal);
//		upgradeButtonView.setTitleColor(upgradeButtonViewTitleColor.withAlphaComponent(0.6), for: .highlighted);
//		topSection.addSubview(upgradeButtonView);
//		upgradeButtonView.snp.makeConstraints ({(make) in
//			make.top.equalTo(hoursRemainingView.snp.bottom).offset(20)
//			make.centerX.equalTo(self.view)
//			make.width.lessThanOrEqualTo(self.view.bounds.width)
//		});
//		upgradeButtonView.layoutIfNeeded();
//		topSectionCenterContentHeight += (upgradeButtonView.frame.height + 20);
//
//
//		nameView.snp.remakeConstraints ({(make) in
//			make.top.equalTo((topSection.frame.height - topSectionCenterContentHeight) / 2).offset(20)
//			make.centerX.equalTo(self.view)
//			make.width.lessThanOrEqualTo(self.view.bounds.width)
//		});
//
//
//
//		self.view.addSubview(bottomSection);
//		bottomSection.snp.makeConstraints ({ (make) in
//			make.width.equalTo(self.view)
//			make.top.equalTo(topSection.snp.bottom)
//			make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
//		});
//
//
//		bottomSection.addSubview(self.collectionView);
//
//		self.collectionView.snp.makeConstraints({(make) -> Void in
//			make.height.equalTo(bottomSection)
//			make.width.equalTo(bottomSection)
//			make.top.right.bottom.left.equalTo(0)
//		});
//
//		API.Account.info { (user, errorMessage) in
//			print(user)
//			print(user?.access?.expiresIn)
//
//			let now = Date();
//			let expirationDate = user?.access?.expiresIn;
//			// extract the diff date components including days, hour, minute
//
//			// todo: fix expirationdate nil
//			let diff = Calendar.current.dateComponents([.minute, .hour, .day], from: now, to: expirationDate!);
//
//			if(expirationDate! < Date()) {
//				self.daysRemainingView.text = String(0);
//				hoursRemainingView.text = "Your premium account is expired.";
//				self.nameView.text = user?.name;
//			} else {
//				self.daysRemainingView.text = String(describing: diff.day!);
//				hoursRemainingView.text = String(describing: diff.hour!) + " Hour" + (diff.hour! > 1 ? "s" : "");
//				self.nameView.text = user?.name;
//
//				print("not passed")
//				print("\(diff.day) days \(diff.hour) hours \(diff.minute) minute")
//			}
//		}
//
//		self.initializeBottomPlayer();
//	}
	
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
		cell.titleView.text = "track name"

		return cell;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		let item = self.homePageItems[indexPath.item];

		var widthAndHeight: CGFloat = 0;

		if(self.device.isPad) {
			widthAndHeight = self.bottomSection.frame.width / 3
		} else {
			widthAndHeight = self.bottomSection.frame.width / 2
		}

		let width = widthAndHeight;
		// 25 is added for label
		let height = widthAndHeight + 25;


		return CGSize(width: width, height: height);
	}
}




class MusicCarouselViewCell : UICollectionViewCell {
	static let ID = "MusicCarouselViewCell";
	
	lazy var albumArtShadowContainer: UIView = {
		let view = UIView();
		view.layer.shadowRadius = 30;
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
		
		return iv;
	}();
	
	lazy var titleView: UILabel = {
		let lb = UILabel();
		lb.textColor = Constants.PRIMARY_TEXT_COLOR;
		lb.font = lb.font.withSize(17);
		lb.textAlignment = .center;
		
		return lb;
	}();
	
	override func layoutSubviews() {
		super.layoutSubviews();
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let bannerImage = UIImage(named: "artwork")!;
		self.artworkImageView.image = bannerImage;
		
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
			make.top.equalTo(self.artworkImageView.snp.bottom).offset(20);
			make.width.equalToSuperview();
			make.height.equalTo(20)
			make.left.right.equalTo(0);
		});
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
