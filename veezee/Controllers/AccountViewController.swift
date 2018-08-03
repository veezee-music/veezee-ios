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
import RxCocoa
import RxSwift
import AnimatedTextInput
import PMAlertController

class AccountViewController: _BasePageViewController, UICollectionViewDataSource, UIGestureRecognizerDelegate {
	
	lazy var nameView: UILabel = {
		let nameView = UILabel();
		nameView.text = self.keychain.get("name") ?? "Your name here";
		nameView.textColor = Constants.PRIMARY_TEXT_COLOR;
		nameView.font = UIFont.systemFont(ofSize: self.device.isPad ? 30 : 23, weight: UIFont.Weight.black);
		
		return nameView;
	}();
	
	lazy var emailView: UILabel = {
		let emailView = UILabel();
		emailView.text = self.keychain.get("email") ?? "Your email here";
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
	
	var userTracksHistory = [Track]();
	var playableList = [PlayableItem]();
	
	var isUserTracksHistoryLoading = BehaviorRelay<Bool>(value: false);
	let disposeBag = DisposeBag();
	
	override func shouldLeaveNavigationTitleUnchanged() -> Bool {
		return true;
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		self.loadRecentlyPlayedTracks(silent: true);
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.loadRecentlyPlayedTracks(silent:)), name: Notification.Name(rawValue: Constants.refreshUserHistoryTracksBroadcastNotificationKey), object: nil);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.setupUI();
		
		self.loadRecentlyPlayedTracks();
		
		let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleCellLongPress(gestureRecognizer:)));
		lpgr.minimumPressDuration = 0.5;
		lpgr.delegate = self;
		lpgr.delaysTouchesBegan = true;
		self.collectionView.addGestureRecognizer(lpgr);
		
		self.layoutChangeNameOrPasswordForm();
		
		self.initializeBottomPlayer();
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated);
		
		NotificationCenter.default.removeObserver(self);
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
		
		let changeNameOrPassword = LGButton();
		changeNameOrPassword.titleString = "Change name or password";
		changeNameOrPassword.titleFontSize = 17;
		changeNameOrPassword.titleColor = Constants.PRIMARY_TEXT_COLOR;
		changeNameOrPassword.cornersRadius = 4;
		changeNameOrPassword.bordersWidth = 1;
		changeNameOrPassword.bordersColor = UIColor.red;
		changeNameOrPassword.bgColor = Constants.PRIMARY_COLOR;
		changeNameOrPassword.addTarget(self, action: #selector(AccountViewController.changeNameOrPasswordButtonTapped), for: .touchUpInside);
		self.topSectionInnerContainer.addSubviewOnce(changeNameOrPassword);
		changeNameOrPassword.snp.remakeConstraints ({(make) in
			make.top.equalTo(emailView.snp.bottom).offset(20)
			make.centerX.equalToSuperview()
			make.width.greaterThanOrEqualTo(0)
		});
		changeNameOrPassword.layoutIfNeeded();
		
		self.topSection.addSubviewOnce(topSectionInnerContainer);
		let topSectionInnerContainerHeight = self.nameView.frame.height + self.emailView.frame.height + changeNameOrPassword.frame.height + 20 + 20;
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
	
	@objc
	func loadRecentlyPlayedTracks(silent: Bool = false) {
		if(!silent) {
			self.isUserTracksHistoryLoading.accept(true);
		}

		API.VEX.tracksHistory(limit: 15) { (tracks, errorMessage) in
			self.isUserTracksHistoryLoading.accept(false);
			
			if(tracks != nil && tracks!.count > 0) {
				self.userTracksHistory.removeAll();
				self.userTracksHistory = tracks!;
				self.collectionView.reloadData();
			}
		}
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
			let item = self.userTracksHistory[indexPath.item];
			NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.trackLongPressedBroadcastNotificationKey), object: self, userInfo: ["track": item, "extraOptions": ["delete-from-user-tracks-history"]]);
		}
		
		self.longPressEnded = true;
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
	
	let nameInputTag = 395543232;
	let passwordInputTag = 01332943;
	
	var changeNameAndPasswordFormContainer = UIView();
	var changeNameAndPasswordFormSubmitButton = LGButton();
}

extension AccountViewController {
	
	@objc
	func changeNameOrPasswordButtonTapped() {
		UIView.animate(withDuration: 0.5) {
			self.changeNameAndPasswordFormContainer.alpha = 1.0;
			self.view.bringSubview(toFront: self.changeNameAndPasswordFormContainer);
		}
	}
	
	@objc
	func changeNameAndPasswordFormCancelButtonTapped() {
		UIView.animate(withDuration: 0.5) {
			self.changeNameAndPasswordFormContainer.alpha = 0.0;
			self.view.sendSubview(toBack: self.changeNameAndPasswordFormContainer);
		}
	}
	
	func submitNameAndPasswordUpdate(name: String, password: String) {
		self.changeNameAndPasswordFormSubmitButton.isLoading = true;
		
		API.Account.updateNameAndPassword(name: name, password: password) { (errorMessage) in
			self.changeNameAndPasswordFormSubmitButton.isLoading = false;
			if(errorMessage == nil) {
				// success
				
				self.nameView.text = name;
				
				self.changeNameAndPasswordFormCancelButtonTapped();
			} else {
				let errorAC = PMAlertController(title: "Error", description: errorMessage!, image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
			}
		}
	}
	
	@objc
	func changeNameAndPasswordFormSubmitButtonTapped() {
		let nameInput = self.changeNameAndPasswordFormContainer.viewWithTag(nameInputTag) as! AnimatedTextInput;
		let passwordInput = self.changeNameAndPasswordFormContainer.viewWithTag(passwordInputTag) as! AnimatedTextInput;
		
		if(nameInput.text == nil || nameInput.text!.count <= 0) {
			return;
		}
		
		self.submitNameAndPasswordUpdate(name: nameInput.text!, password: passwordInput.text!);
	}
	
	func layoutChangeNameOrPasswordForm() {
		let containerViewWidth = self.device.isPad ? ((self.view.frame.width / 1.5) + (20 * 2)) : self.view.frame.width - 50;
		
		changeNameAndPasswordFormContainer.layer.zPosition = 10;
		changeNameAndPasswordFormContainer.cornerRadius = 4;
		changeNameAndPasswordFormContainer.clipsToBounds = true;
		changeNameAndPasswordFormContainer.backgroundColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		changeNameAndPasswordFormContainer.alpha = 0;
		self.view.addSubview(changeNameAndPasswordFormContainer);
		changeNameAndPasswordFormContainer.snp.makeConstraints({(make) -> Void in
			make.width.equalTo(containerViewWidth);
			make.centerX.centerY.equalTo(self.view)
		});
		changeNameAndPasswordFormContainer.layoutIfNeeded();
		
		var childViewsFullHeight: CGFloat = 0;
		
		let titleView = UILabel();
		titleView.text = "Change name and password";
		titleView.textColor = .white;
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		titleView.font = boldFont.withSize(20);
		
		changeNameAndPasswordFormContainer.addSubview(titleView);
		titleView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(30)
			make.centerX.equalTo(self.view)
		});
		titleView.layoutIfNeeded();
		childViewsFullHeight += titleView.bounds.height + 30;
		
		let nameInput = AnimatedTextInput();
		nameInput.tag = nameInputTag;
		nameInput.style = CustomAnimatedTextInputStyle();
		nameInput.type = .standard;
		nameInput.placeHolderText = "New name";
		
		let passwordInput = AnimatedTextInput();
		passwordInput.tag = passwordInputTag;
		passwordInput.style = CustomAnimatedTextInputStyle();
		passwordInput.type = .password(toggleable: true);
		passwordInput.placeHolderText = "New password (Optional)";
		
		changeNameAndPasswordFormContainer.addSubview(nameInput);
		nameInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(titleView.snp.bottom)
			make.left.right.equalTo(0)
		});
		nameInput.layoutIfNeeded();
		childViewsFullHeight += nameInput.bounds.height;
		
		changeNameAndPasswordFormContainer.addSubview(passwordInput);
		passwordInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(nameInput.snp.bottom)
			make.left.right.equalTo(0)
		});
		passwordInput.layoutIfNeeded();
		childViewsFullHeight += passwordInput.bounds.height;
		
		changeNameAndPasswordFormSubmitButton.titleString = "Submit";
		changeNameAndPasswordFormSubmitButton.titleFontSize = 18;
		changeNameAndPasswordFormSubmitButton.titleColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		changeNameAndPasswordFormSubmitButton.cornersRadius = 4;
		changeNameAndPasswordFormSubmitButton.bgColor = Constants.ACCENT_COLOR;
		changeNameAndPasswordFormSubmitButton.shadowRadius = 4;
		changeNameAndPasswordFormSubmitButton.shadowOpacity = 2;
		changeNameAndPasswordFormSubmitButton.shadowOffset = CGSize(width: 0, height: 1);
		changeNameAndPasswordFormSubmitButton.shadowColor = Constants.ACCENT_COLOR;
		changeNameAndPasswordFormSubmitButton.addTarget(self, action: #selector(AccountViewController.changeNameAndPasswordFormSubmitButtonTapped), for: .touchUpInside);
		changeNameAndPasswordFormSubmitButton.loadingColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		changeNameAndPasswordFormSubmitButton.loadingString = "Please wait...";
		changeNameAndPasswordFormSubmitButton.loadingSpinnerColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		
		changeNameAndPasswordFormContainer.addSubview(changeNameAndPasswordFormSubmitButton);
		changeNameAndPasswordFormSubmitButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(passwordInput.snp.bottom).offset(30)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		changeNameAndPasswordFormSubmitButton.layoutIfNeeded();
		childViewsFullHeight += (changeNameAndPasswordFormSubmitButton.bounds.height + 30);
		
		let cancelButton = UIButton();
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14);
		cancelButton.setTitle("Cancel", for: .normal);
		cancelButton.setTitleColor(UIColor.lightGray, for: .normal);
		cancelButton.setTitleColor(UIColor.gray, for: .highlighted);
		
		changeNameAndPasswordFormContainer.addSubview(cancelButton);
		cancelButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(changeNameAndPasswordFormSubmitButton.snp.bottom).offset(30 / 2)
			make.left.right.equalTo(0)
		});
		cancelButton.addTarget(self, action: #selector(AccountViewController.changeNameAndPasswordFormCancelButtonTapped), for: .touchUpInside);
		cancelButton.layoutIfNeeded();
		childViewsFullHeight += (cancelButton.bounds.height + 30);
		
		changeNameAndPasswordFormContainer.snp.makeConstraints({(make) -> Void in
			make.centerX.centerY.equalTo(self.view)
			make.width.equalTo(containerViewWidth)
			make.height.equalTo(childViewsFullHeight)
		});
	}
	
}

extension AccountViewController : UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.userTracksHistory.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.userTracksHistory[indexPath.item];
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCarouselViewCell.ID, for: indexPath) as! MusicCarouselViewCell;
		cell.titleView.text = item.title;
		if(item.image != nil) {
			cell.artworkImageView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: item.image!), placeholder: UIImage(named: "artwork"));
		}
		
		return cell;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		let item = self.userTracks[indexPath.item];
		
		if(self.playableList.count <= 0) {
			self.playableList = generatePlayableListFromTracksList(list: self.userTracksHistory);
			self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: indexPath.item, mode: .normal);
		} else {
			// playable list already initialized
			self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: indexPath.item, mode: .normal);
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return self.carouselSize;
	}
	
	func sendPlayBroadcastNotification(playableList: [PlayableItem], currentPlayableItemIndex: Int, mode: AudioPlayerMode) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : playableList, "currentPlayableItemIndex": currentPlayableItemIndex, "mode": mode]);
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
