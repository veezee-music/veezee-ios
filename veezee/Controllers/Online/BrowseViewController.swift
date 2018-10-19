//
//  ViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/26/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import UIKit
import SnapKit
import DeviceKit
import AVFoundation
import Kingfisher
import PMAlertController
import KeychainSwift
import SwiftIcons
import CouchbaseLiteSwift
import Sheeeeeeeeet
import PKHUD
import RxSwift
import RxCocoa

class BrowseViewController: _BasePageViewController {
	
	lazy var navigationBarHeight = navigationController?.navigationBar.frame.size.height;
	
	let musicSmallCardInsetSize: CGFloat = 15;
	let musicSmallCardSideSizeHorizontal: CGFloat = 150;
	lazy var musicSmallCardSideSizeVertical = musicSmallCardSideSizeHorizontal + 50;
	
	private var _homePageItems = [HomePageItem]();
	var homePageItems: [HomePageItem] {
		set {
			var newCollection = [HomePageItem]();
			for n in newValue {
				newCollection.append(n);
			}
			// one more spacer just to make it look better
			var spacer = HomePageItem();
			spacer.type = HomePageItemType.Spacer;
			newCollection.append(spacer);
			
			_homePageItems = newCollection;
			self.collectionView.reloadData();
		}
		get { return _homePageItems }
	}
	
	lazy var collectionView = self.getCollectionView();
	
	lazy var retryButton: LGButton = {
		let retryButton = LGButton();
		retryButton.titleString = "Retry";
		retryButton.titleFontSize = 18;
		retryButton.titleColor = .white;
		retryButton.cornersRadius = 4;
		retryButton.bgColor = Constants.ACCENT_COLOR;
		retryButton.shadowRadius = 4;
		retryButton.shadowOpacity = 2;
		retryButton.shadowOffset = CGSize(width: 0, height: 1);
		retryButton.shadowColor = Constants.ACCENT_COLOR;
		retryButton.addTarget(self, action: #selector(BrowseViewController.loadHomePageLists), for: .touchUpInside);
		
		return retryButton;
	}();
	
	var isLoading = BehaviorRelay<Bool>(value: false);
	let disposeBag = DisposeBag();
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.viewReappearedFromForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = Constants.PRIMARY_COLOR;
		// set up observers
		self.setupLoadingObserver();
		
		self.setupUI();
		
		self.loadHomePageLists();
		
		self.initializeBottomPlayer();
	}
	
	@objc
	func loadHomePageLists(silent: Bool = false) {
		if(!silent) {
			self.isLoading.accept(true);
		}
		
		API.Lists.home(handler: { (list, errorMessage) in
			self.isLoading.accept(false);
			
			// todo: error in case of network issue must be invistigated
			if(list == nil) {
				let errorAC = PMAlertController(title: "Error", description: errorMessage ?? "Unknown error", image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
				
				self.retryButton.isHidden = false;
				self.view.bringSubview(toFront: self.retryButton);
				
				return;
			}
			
			if(list != nil) {
				self.retryButton.isHidden = true;
				// destroy the existing collection view and replace it with a new and clean instance
				self.collectionView.removeFromSuperview();
				self.collectionView = self.getCollectionView();
				self.setupUI();
				
				self.homePageItems.removeAll();
				self.homePageItems = list!;
			}
			
		});
	}
	
	@objc
	func settingsButtonPressed(_ sender: AnyObject) {
		let settingsScreen = SettingsViewController();
		self.navigationController?.pushViewController(settingsScreen, animated: true);
	}
	
	override func addNavigationButtons() {
		let settingsBtn = UIBarButtonItem();
		settingsBtn.target = self;
		settingsBtn.action = #selector(self.settingsButtonPressed(_:));
		settingsBtn.setIcon(icon: .ionicons(.iosGear), iconSize: 30, color: Constants.PRIMARY_TEXT_COLOR);
		self.navigationItem.rightBarButtonItem = settingsBtn;
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil);
	}
	
	override func viewReappearedFromForeground() {
		super.viewReappearedFromForeground();
		
		// FIXME: Causes issues with bottom player
//		self.loadHomePageLists(silent: true);
	}
}

extension BrowseViewController {
	
	func setupLoadingObserver() {
		self.isLoading.asObservable()
			.subscribe(onNext: { loading in
				loading ? HUD.showProgress() : HUD.hide(animated: true);
			})
			.disposed(by: self.disposeBag);
	}
	
}

extension BrowseViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.homePageItems[indexPath.item];
		
		if(item.type == HomePageItemType.Album) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSmallDoubleRowCollectionViewCell.ID, for: indexPath) as! HorizontalSmallDoubleRowCollectionViewCell;
			cell.navigationDelegate = self;
			cell.dataList = item.albumList!;
			cell.collectionViewTitleView.text = item.title ?? "";
			return cell;
		} else if (item.type == HomePageItemType.Header) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalLargeCollectionViewCell.ID, for: indexPath) as! HorizontalLargeCollectionViewCell;
			cell.navigationDelegate = self;
			cell.dataList = item.headerList!;
			return cell;
		} else if(item.type == HomePageItemType.Track) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalTinyTripleRowCollectionViewCell.ID, for: indexPath) as! HorizontalTinyTripleRowCollectionViewCell;
			cell.navigationDelegate = self;
			cell.dataList = item.trackList!;
			cell.collectionViewTitleView.text = item.title ?? "";
			return cell;
		} else if(item.type == HomePageItemType.Genre) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalTinyOneRowCollectionViewCell.ID, for: indexPath) as! HorizontalTinyOneRowCollectionViewCell;
			cell.dataList = item.genreList!;
			cell.collectionViewTitleView.text = item.title ?? "";
			return cell;
		} else if(item.type == HomePageItemType.CompactAlbum) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompactListCollectionViewCell.ID, for: indexPath) as! CompactListCollectionViewCell;
			cell.navigationDelegate = self;
			cell.dataList = item.albumList!;
			cell.collectionViewTitleView.text = item.title ?? "";
			return cell;
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpacerCollectionViewCell.ID, for: indexPath) as! SpacerCollectionViewCell;
		return cell;
	}
	
}

extension BrowseViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.homePageItems.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let item = self.homePageItems[indexPath.item];
		
		if(item.type == HomePageItemType.Album) {
			return CGSize(width: view.bounds.width, height: HorizontalSmallDoubleRowCollectionViewCell.cellHeight * 2 + 4 * HorizontalSmallDoubleRowCollectionViewCell.insetSize + 25);
		} else if (item.type == HomePageItemType.Header) {
			let magicPercentage: CGFloat = self.device.isPad ? 75.0 : 83.0;
			let width = self.view.frame.width * magicPercentage / 100;
			let height = width / 1.8;
			
			return CGSize(width: view.bounds.width, height: height + 72 + 2 * HorizontalLargeCollectionViewCell.insetSize);
		} else if(item.type == HomePageItemType.Track) {
			return CGSize(width: view.bounds.width, height: HorizontalTinyTripleRowCollectionViewCell.cellHeight * 3 + 5 * HorizontalTinyTripleRowCollectionViewCell.insetSize + 25);
		} else if(item.type == HomePageItemType.Genre) {
			return CGSize(width: view.bounds.width, height: HorizontalTinyOneRowCollectionViewCell.cellHeight + 4.5 * HorizontalTinyOneRowCollectionViewCell.insetSize);
		} else if(item.type == HomePageItemType.CompactAlbum) {
			let height: CGFloat = (CompactListCollectionViewCell.cellHeight + CompactListCollectionViewCell.insetSize) * CGFloat(item.albumList?.count ?? 0) + CompactListCollectionViewCell.cellHeight * 1.5;
			return CGSize(width: view.bounds.width, height: height);
		}
		
		// spacer collection view
		return CGSize(width: view.bounds.width, height: BottomPlayer.Height);
	}
}

extension BrowseViewController {
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator);
		
		//	coordinator.animate(alongsideTransition: nil, completion: { _ in
		//		self.reInitializeBottomPlayer();
		//	});
		
		self.collectionView.removeFromSuperview();
		self.collectionView = self.getCollectionView();
		self.setupUI();
		self.initializeBottomPlayer();
	}
	
	func setupUI() {
		self.view.addSubviewOnce(self.retryButton);
		self.retryButton.snp.remakeConstraints ({ (make) in
			make.center.equalToSuperview()
		});
		self.retryButton.isHidden = true;
		
		self.view.addSubviewOnce(self.collectionView);
		self.collectionView.snp.remakeConstraints({(make) -> Void in
			make.width.equalTo(self.view);
			make.height.equalTo(self.view);
			make.top.bottom.equalTo(0);
		});
		self.collectionView.collectionViewLayout.invalidateLayout();
	}
	
	func getCollectionView() -> UICollectionView {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getCollectionViewFlowLayout());
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(HorizontalSmallDoubleRowCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalSmallDoubleRowCollectionViewCell.ID);
		collectionView.register(HorizontalLargeCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalLargeCollectionViewCell.ID);
		collectionView.register(HorizontalTinyTripleRowCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalTinyTripleRowCollectionViewCell.ID);
		collectionView.register(HorizontalTinyOneRowCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalTinyOneRowCollectionViewCell.ID);
		collectionView.register(CompactListCollectionViewCell.self, forCellWithReuseIdentifier: CompactListCollectionViewCell.ID);
		collectionView.register(SpacerCollectionViewCell.self, forCellWithReuseIdentifier: SpacerCollectionViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}
	
	func getCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = self.musicSmallCardInsetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = self.musicSmallCardInsetSize;
		collectionViewFlowLayout.sectionInset = .zero;
		
		return collectionViewFlowLayout;
	}
	
}
