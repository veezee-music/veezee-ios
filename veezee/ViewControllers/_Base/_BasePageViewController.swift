//
//  _BasePageViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/28/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import MediaPlayer
import KeychainSwift
import PMAlertController
import DeviceKit
import Sheeeeeeeeet
import Kingfisher
import MarqueeLabel

class _BasePageViewController: _BaseCommonViewController, BottomPlayerDelegate, NavigationControllerDelegate {
	
	lazy var bottomPlayerBackground: UIImageView? = nil;
	
	var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?;
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		self.bottomPlayer.resetVisibility();
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.viewReappearedFromForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.onInitiatePlayerForPlayableList(_:)), name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.onShowTrackActionSheet(_:)), name: Notification.Name(rawValue: Constants.trackLongPressedBroadcastNotificationKey), object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.onStopAndClearPlayers(_:)), name: Notification.Name(rawValue: Constants.audioPlayerStopAndClearPlayersBroadcastNotificationKey), object: nil);
		
		self.registerSettingsBundle();
		NotificationCenter.default.addObserver(self, selector: #selector(self.appSettingsBundleChanged), name: UserDefaults.didChangeNotification, object: nil);
		// just for initialization this time
		self.appSettingsBundleChanged();
		
		let title = self.getTitle();
		if(!self.shouldLeaveNavigationTitleUnchanged()) {
			if(title != nil) {
				self.title = title;
			} else {
				self.addBannerImageToNavigationBar();
			}
		}
		
		self.addNavigationButtons();
		
		var backButtonText = "Back";
		if(shouldOmmitBackNavigationButtonText()) {
			backButtonText = "";
		}
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonText, style: .plain, target: nil, action: nil);
		
		if(self.bottomPlayer.frame != .zero) {
			self.bottomPlayer.resetVisibility();
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		// This fixes a UI bug where the defualt window color (black) is shown during VC transitions
		UIApplication.shared.keyWindow?.backgroundColor = Constants.PRIMARY_COLOR;
	}
	
	@objc
	func viewReappearedFromForeground() {
		self.bottomPlayer.resetVisibility();
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated);
		
		// This is very important
		// Removing observers when VC has disappeard prevents BaseVC from recieving duplicate notifications from BaseVC subclasses
		NotificationCenter.default.removeObserver(self);
	}
	
	func addBannerImageToNavigationBar() {
		var bannerImage = UIImage(named: "logotype-white")!;
		if(Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR) {
			bannerImage = UIImage(named: "logotype-black")!;
		}
		let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 30));
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 30));
		imageView.contentMode = .scaleAspectFit;
		imageView.image = bannerImage;
		logoContainer.addSubview(imageView);
		self.navigationItem.titleView = logoContainer;
	}
	
	func shouldLeaveNavigationTitleUnchanged() -> Bool {
		return false;
	}
	
	func getTitle() -> String? {
		return nil;
	}
	
	func addNavigationButtons() {
		
	}
	
	func shouldOmmitBackNavigationButtonText() -> Bool {
		return false;
	}
	
	let bottomPlayer = BottomPlayer(frame: CGRect.zero);
	func initializeBottomPlayer() {
		if(bottomPlayer.frame != .zero) {
			return;
		}
		self.bottomPlayer.delegate = self;
		self.view.addSubviewOnce(self.bottomPlayer);
		self.view.bringSubview(toFront: self.bottomPlayer);
		bottomPlayer.snp.remakeConstraints({(make) -> Void in
			make.height.equalTo(BottomPlayer.Height);
			make.bottom.equalTo(0)//.inset((self.tabBarController?.tabBar.bounds.height)!);
			make.left.right.equalTo(0)
		});
		bottomPlayer.layoutIfNeeded();
		bottomPlayer.setLayouts();
	}
	
	@objc
	func bottomPlayerTapped() {
		self.openPlayerModal();
	}
	
	func closeBottomPlayer() {
		// don't explicitly call this on the main threat or get ready for weird bugs
		self.bottomPlayer.isHidden = true;
	}
	
	@objc
	func bottomPlayerGestureHandler(gesture: UISwipeGestureRecognizer) -> Void {
		if gesture.direction == UISwipeGestureRecognizerDirection.right {
			// Swipe right
		}
		else if gesture.direction == UISwipeGestureRecognizerDirection.left {
			// Swipe left
		}
		else if gesture.direction == UISwipeGestureRecognizerDirection.up {
			// Swipe up
			self.openPlayerModal();
		}
		else if gesture.direction == UISwipeGestureRecognizerDirection.down {
			// Swipe down
		}
	}
	
	func openPlayerModal() {
		let playerScreen = MusicPlayerViewController();
		playerScreen.modalPresentationStyle = UIModalPresentationStyle.custom;
		playerScreen.modalPresentationCapturesStatusBarAppearance = true;
		self.modalPresentationStyle = .custom;
		self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: playerScreen);
		playerScreen.transitioningDelegate = self.halfModalTransitioningDelegate;
		
		present(playerScreen, animated: true, completion: nil);
	}
	
	func openPlayerModalAndPlayFromPlayableList(playableList: [PlayableItem], currentPlayableItemIndex: Int) {
		_ = MusicPlayerViewController(playableList: playableList, currentPlayableItemIndex: currentPlayableItemIndex);
	}
	
	@objc
	func onInitiatePlayerForPlayableList(_ notification: Notification) {
		if let dict = notification.userInfo as Dictionary? {
			if let playableList = dict["playableList"] as? [PlayableItem], var currentPlayableItemIndex = dict["currentPlayableItemIndex"] as? Int {
				let mode = dict["mode"] as? AudioPlayerMode;
				if((self.audioPlayer.state == AudioPlayerState.fsAudioStreamPlaying || self.audioPlayer.state == AudioPlayerState.fsAudioStreamBuffering) && self.audioPlayer.queue.first?._id == playableList.first?._id && self.audioPlayer.currentItem?._id == playableList[currentPlayableItemIndex]._id) {
					// we are already playing that file on the same playablelist, keep playling it and just open the player screen
					self.openPlayerModal();
				} else {
					if(mode != nil) {
						self.audioPlayer.mode = mode!;
						if(mode == AudioPlayerMode.shuffle) {
							let randomIndex = Int(arc4random_uniform(UInt32(playableList.count)));
							currentPlayableItemIndex = randomIndex;
						}
					} else {
						self.audioPlayer.mode = AudioPlayerMode.normal;
					}
					self.openPlayerModalAndPlayFromPlayableList(playableList: playableList, currentPlayableItemIndex: currentPlayableItemIndex);
				}
			}
		}
	}
	
	@objc
	func onStopAndClearPlayers(_ notification: Notification) {
		self.closeBottomPlayer();
		self.audioPlayer.stop();
	}
	
	@objc
	func onShowAlbumPage(_ notification: Notification) {
		if let dict = notification.userInfo as Dictionary? {
			if let album = dict["album"] as? Album {
				let vc = AlbumViewController(album: album);
				self.navigationController?.pushViewController(vc, animated: true);
			}
		}
	}
	
	@objc
	func onShowTrackActionSheet(_ notification: Notification) {
		if let dict = notification.userInfo as Dictionary? {
			if let track = dict["track"] as? Track {
				self.showTrackActionSheet(track: track);
			}
		}
	}
}

extension _BasePageViewController {
	
	func navigateToVCFor(album: Album) {
		let vc = AlbumViewController(album: album);
		self.navigationController?.pushViewController(vc, animated: true);
	}
	
	func navigateToVCFor(tracksList: [Track]) {
		let vc = AllTracksListViewController();
		self.navigationController?.pushViewController(vc, animated: true);
	}
	
	func navigateToVCFor(albumsList: [Album]) {
		let vc = AllAlbumsPlaylistsListViewController(type: AlbumsTracksListPageType.album);
		self.navigationController?.pushViewController(vc, animated: true);
	}
	
	func navigateToVCFor(playLists: [Album]) {
		let vc = AllAlbumsPlaylistsListViewController(type: AlbumsTracksListPageType.playlist);
		self.navigationController?.pushViewController(vc, animated: true);
	}
	
}
