//
//  MusicPlayerViewController.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/2/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import SnapKit
import SwiftIcons
import CoreAnimator
import DeviceKit
import MediaPlayer
import Kingfisher
import RxSwift
import RxCocoa
import MaterialComponents.MaterialSlider
import MarqueeLabel
import NVActivityIndicatorView

class MusicPlayerViewController: HalfModalViewController, AudioPlayerDelegate {
	
	let device = Device();
	
	var statusBarShouldBeHidden = false;
	
	override var prefersStatusBarHidden: Bool {
		return statusBarShouldBeHidden;
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent;
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .slide;
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		if(!self.device.isPad && self.device != .iPhoneX) {
			statusBarShouldBeHidden = true;
			UIView.animate(withDuration: 0.25) {
				self.setNeedsStatusBarAppearanceUpdate();
			}
		}
		
		// set the progress slider before page is shown to the user
		if(self.audioPlayer.currentItem != nil) {
			let itemDuration = self.audioPlayer.currentItemDuration ?? 0;
			let itemProgression = self.audioPlayer.currentItemProgression ?? 0;
			let percentage = (itemDuration > 0 ? CGFloat(itemProgression / itemDuration) * 100 : 0)

			self.progressPassedView.text = format(duration: itemProgression);
			self.progressBarView.value = percentage;
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.onStopAndClearPlayers(_:)), name: Notification.Name(rawValue: Constants.audioPlayerStopAndClearPlayersBroadcastNotificationKey), object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerWillStartPlaying(_:)), name: Notification.Name(rawValue: AudioPlayer.Notifications.willStartPlayingItem), object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerDidChangeState(_:)), name: Notification.Name(rawValue: AudioPlayer.Notifications.didChangeState), object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.onPlaybackProgression), name: Notification.Name(rawValue: AudioPlayer.Notifications.didProgressTo), object: nil);
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated);
		
		NotificationCenter.default.removeObserver(self);
	}
	
	@objc
	func audioPlayerWillStartPlaying(_ notification: Notification) {
		self.currentItemDuration.accept(self.audioPlayer.currentItemDuration);
		self.currentItem.accept(self.audioPlayer.currentItem);
	}
	
	@objc
	func audioPlayerDidChangeState(_ notification: Notification) {
		self.audioPlayerState.accept(self.audioPlayer.state);
	}
	
	func onWillStartPlaying(item: PlayableItem?, duration: TimeInterval) {
		
	}
	
	@objc
	func onPlaybackProgression() {
		self.currentItemProgression.accept(self.audioPlayer.currentItemProgression);
	}
	
	func onStateChange(state: AudioPlayerState) {
		
	}
	
	func onItemChange(item: PlayableItem?, index: Int) {
		self.currentItem.accept(item);
	}
	
	func onMetaDataAvailable(metaData: [AnyHashable : Any]?) {
		
	}
	
	func onFailure(streamingError: AudioPlayerError, error: String?) {
		
	}
	
	func onFileCached(cachedFileName: String) {
		
	}
	
	func onCompletion() {
		
	}
	
	func onQueueFinished() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerStopAndClearPlayersBroadcastNotificationKey), object: self, userInfo: nil);
	}
	
	var playableList = [PlayableItem]();
	
	let disposeBag = DisposeBag();
	let audioPlayer = AudioPlayer.shared;
	var currentItem = BehaviorRelay<PlayableItem?>(value: nil);
	var currentItemImage = BehaviorRelay<UIImage?>(value: nil);
	var currentItemDuration = BehaviorRelay<TimeInterval?>(value: nil);
	var currentItemProgression = BehaviorRelay<TimeInterval?>(value: nil);
	var audioPlayerState = BehaviorRelay<AudioPlayerState?>(value: AudioPlayerState.playing);
	
	lazy var screenHieght: CGFloat = 0;
	lazy var screenWidth: CGFloat = 0;
	
	lazy var containerView : UIView = {
		let containerView = UIView();
		
		return containerView;
	}();
	
	lazy var artwork = UIImage(named: "artwork");
	
	lazy var artworkView: UIImageView = {
		let artworkView = UIImageView();
		artworkView.clipsToBounds = true;
		artworkView.layer.masksToBounds = true;
		artworkView.contentMode = .scaleAspectFit;
		artworkView.layer.cornerRadius = 4;
		
		return artworkView;
	}();
	
	lazy var progressBarView: MDCSlider = {
		let progressBar = MDCSlider();
		progressBar.color = Constants.ACCENT_COLOR;
		progressBar.addTarget(self, action: #selector(self.onProgressBarValueChanged(slider:event:)), for: .valueChanged);
		progressBar.maximumValue = 100.0;
		progressBar.isContinuous = false;
		progressBar.isThumbHollowAtStart = false;
		
		return progressBar;
	}();
	
	lazy var progressPassedView: UILabel = {
		let progressPassed = UILabel();
		progressPassed.textColor = self.audioPlayer.currentItem?.colors.accentColor;
		progressPassed.font = progressPassed.font.withSize(11);
		progressPassed.text = "0:00";
		
		return progressPassed;
	}();
	
	lazy var durationView: UILabel = {
		let duration = UILabel();
		duration.textColor = self.audioPlayer.currentItem?.colors.accentColor;
		duration.font = duration.font.withSize(11);
		duration.text = "0:00";
		
		return duration;
	}();
	
	lazy var shuffleButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosShuffleStrong), iconSize: (self.device.isPad ? 7.38 : 6) * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.addTarget(self, action: #selector(self.shuffleButtonPressed), for: .touchUpInside);
		
		return button;
	}();
	
	lazy var skipBackwardButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosRewind), iconSize: (self.device.isPad ? 7.38 : 5) * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.addTarget(self, action: #selector(self.skipBackwardButtonPressed), for: .touchUpInside);
		
		return button;
	}();
	
	lazy var playPauseStopButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.pause), iconSize: (self.device.isPad ? 12 : 9) * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.addTarget(self, action: #selector(self.playButtonPressed), for: .touchUpInside);
		
		return button;
	}();
	
	lazy var skipForwardButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosFastforward), iconSize: (self.device.isPad ? 7.38 : 5) * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.addTarget(self, action: #selector(self.skipForwardButtonPressed), for: .touchUpInside);
		
		return button;
	}();
	
	lazy var repeatButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosLoopStrong), iconSize: (self.device.isPad ? 7.38 : 6) * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.addTarget(self, action: #selector(self.repeatButtonPressed), for: .touchUpInside);
		
		return button;
	}();
	
	lazy var titleView: UILabel = {
		let titleText = MarqueeLabel.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), duration: 10.0, fadeLength: 10.0);
		titleText.trailingBuffer = 40;
		titleText.animationDelay = 3;
		titleText.textColor = self.audioPlayer.currentItem?.colors.primaryColor;
		let boldFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize);
		titleText.font = boldFont.withSize(self.device.isPad && isDeviceLandscape() ? (4 * self.screenHieght / 100) : (6 * self.screenHieght / 100));
		
		return titleText;
	}();
	
	lazy var artistView: UILabel = {
		let artistText = UILabel();
		artistText.textColor = self.audioPlayer.currentItem?.colors.accentColor;
		artistText.font = artistText.font.withSize(4.67 * self.screenHieght / 100);
		
		return artistText;
	}();
	
	lazy var mpVolumeSlider: UISlider = {
		var mpVolumeSlider = UISlider();
		for subview in MPVolumeView().subviews {
			guard let volumeSlider = subview as? UISlider else { continue; }
			volumeSlider.tintColor = self.audioPlayer.currentItem?.colors.accentColor;
			mpVolumeSlider = volumeSlider
		}

		return mpVolumeSlider;
	}();
	
	lazy var volumeUpButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosVolumeHigh), iconSize: 6.15 * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal);
		
		return button;
	}();
	
	lazy var volumeDownButton: IconedButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosVolumeLow), iconSize: 6.15 * self.screenHieght / 100, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
		button.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal);
		
		return button;
	}();
	
	var controlsStackView: UIStackView? = nil;
	
	var chevronDownIcon: IconedButton?;
	
	init() {
		super.init(nibName: nil, bundle: nil);
		
		self.setupObservers();
		
		self.audioPlayer.delegate = self;
		
		if(self.audioPlayer.queue != nil) {
			self.playableList = self.audioPlayer.queue!.items;
		}
		self.currentItem.accept(self.audioPlayer.currentItem);
	}
	
	init(playableList: [PlayableItem], currentPlayableItemIndex: Int) {
		super.init(nibName: nil, bundle: nil);
		
		self.setupObservers();
		
		self.audioPlayer.delegate = self;
		
		self.playableList = playableList;
		
		self.audioPlayer.play(items: playableList, startAtIndex: currentPlayableItemIndex);
	}
	
	func setupObservers() {
		self.setupAudioPlayerStateObserver();
		self.setupCurrentAudioItemObserver();
		self.setupCurrentAudioItemDurationObserver();
		self.setupCurrentAudioItemProgressionObserver();
		self.setupCurrentAudioItemImage();
	}
	
	func loadImageToArtworkViewAndPlayableItem(imageUrl: String?) {
		if(imageUrl == nil) {
			return;
		}
		let imageUrl = URL.createFrom(localOrRemoteAddress: imageUrl!);
		KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: imageUrl), options: nil, progressBlock: nil) {
			(image, error, cacheType, imageURL) -> () in
			self.audioPlayer.currentItem?.artworkImage = image;
			self.artworkView.image = image;
		};
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	var backgroundBlurredImageView = UIImageView();
	override func viewDidLoad() {
		super.viewDidLoad();
		self.backgroundBlurredImageView.frame = self.view.frame;
		
		self.screenWidth = self.view.bounds.width;
		
		let window = UIApplication.shared.keyWindow;
		let topPadding = window?.safeAreaInsets.top;
		
		self.view.addSubview(self.containerView);
		self.containerView.snp.remakeConstraints ({(make) -> Void in
			make.top.equalTo(topPadding!)
			make.bottom.equalTo(0)
			make.width.equalToSuperview();
			make.left.right.equalTo(0)
		});
		self.containerView.layoutIfNeeded();
		
		if(self.device.isPhone || self.device.isPod) {
			self.screenHieght = self.view.bounds.height * 75 / 100;
			
			self.chevronDownIcon = IconedButton();
			self.chevronDownIcon?.initButton(icon: .ionicons(.androidArrowDropdownCircle), iconSize: 30, color: self.audioPlayer.currentItem!.colors.accentColor, forState: .normal);
			if(self.chevronDownIcon != nil) {
				self.containerView.addSubview(self.chevronDownIcon!);
			}
			self.chevronDownIcon?.snp.remakeConstraints ({ (make) in
				make.top.left.equalTo(10)
				make.width.height.equalTo(30)
			});
			self.chevronDownIcon?.layer.zPosition = 88;
			self.chevronDownIcon?.layoutIfNeeded();
			
			self.containerView.addSubview(self.artworkView);
			self.artworkView.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(0)
				make.width.height.equalTo(self.view.frame.width)
			});
			self.artworkView.layer.cornerRadius = 0;
			self.artworkView.layoutIfNeeded();
			self.artworkView.image = artwork;
			
			let heightLeft = self.containerView.frame.height - (self.artworkView.frame.height);
			
			let progressContainer = UIView();
			self.containerView.addSubview(progressContainer)
			progressContainer.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(self.artworkView.snp.bottom)
				make.left.right.equalTo(0)
				make.height.equalTo(heightLeft / 5)
			});
			progressContainer.layoutIfNeeded();
			
			progressContainer.addSubview(self.progressBarView)
			//progressBar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
			self.progressBarView.snp.remakeConstraints ({(make) -> Void in
				make.center.equalTo(progressContainer)
				make.width.equalTo(progressContainer.frame.width - 30)
				make.height.equalTo(10)
			});

			progressContainer.addSubview(self.progressPassedView);
			self.progressPassedView.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(self.progressBarView.snp.bottom).offset(5)
				make.left.equalTo(0).offset(20)
			});

			progressContainer.addSubview(self.durationView);
			self.durationView.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(self.progressBarView.snp.bottom).offset(5)
				make.right.equalTo(0).inset(20)
			});
			
			let titlesContainer = UIView();
			self.containerView.addSubview(titlesContainer)
			titlesContainer.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(progressContainer.snp.bottom)
				make.left.right.equalTo(0)
				make.height.greaterThanOrEqualTo(heightLeft / 4)
			});
			titlesContainer.layoutIfNeeded();

			let boldFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize);
			self.titleView.font = boldFont.withSize(4 * self.screenHieght / 100) // 25

			self.artistView.font = self.artistView.font.withSize(3 * self.screenHieght / 100); // 19
			
			let titlesStackView = UIStackView(arrangedSubviews: [self.titleView, self.artistView]);
			titlesStackView.axis = .vertical;
			titlesStackView.alignment = .center
			titlesStackView.distribution = .fillEqually;
			titlesContainer.addSubview(titlesStackView);
			titlesStackView.snp.remakeConstraints ({(make) -> Void in
				make.center.equalTo(titlesContainer)
				make.left.equalTo(20)
				make.right.equalTo(0).inset(20)
				make.height.equalTo(heightLeft / 5)
			});
			
			let controlsContainer = UIView();
			self.containerView.addSubview(controlsContainer)
			controlsContainer.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(titlesContainer.snp.bottom)
				make.left.right.equalTo(0)
				make.height.equalTo(heightLeft / 4)
			});
			controlsContainer.layoutIfNeeded();
			
			self.controlsStackView = UIStackView(arrangedSubviews: [self.shuffleButton, self.skipBackwardButton, self.playPauseStopButton, self.skipForwardButton, self.repeatButton]);
			self.controlsStackView?.axis = .horizontal;
			self.controlsStackView?.distribution = .equalCentering;
			controlsContainer.addSubviewOnce(self.controlsStackView);
			
			self.controlsStackView?.snp.remakeConstraints ({(make) -> Void in
				make.centerY.equalTo(controlsContainer).offset(10) // the offset is really not necessary but i just feel like the player looks better with this
				make.centerX.equalTo(controlsContainer)
				make.width.equalTo(controlsContainer.frame.width / 1.2)
				make.height.equalTo(heightLeft / 4)
			});
			
			let volumesContainer = UIView();
			self.containerView.addSubview(volumesContainer)
			volumesContainer.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(controlsContainer.snp.bottom)
				make.left.right.equalTo(0)
				make.height.equalTo(heightLeft / 4)
			});
			volumesContainer.layoutIfNeeded();
			
			volumesContainer.addSubview(self.mpVolumeSlider);
			self.mpVolumeSlider.snp.remakeConstraints({(make) -> Void in
				make.center.equalTo(volumesContainer)//.offset(-5)
				make.width.equalTo(volumesContainer.frame.width / 1.4)
			});
			
			volumesContainer.addSubview(self.volumeDownButton);
			self.volumeDownButton.snp.remakeConstraints({(make) -> Void in
				make.centerY.equalTo(self.mpVolumeSlider)
				make.right.equalTo(self.mpVolumeSlider.snp.left)
				make.width.height.equalTo(30)
			});
			
			volumesContainer.addSubview(self.volumeUpButton);
			self.volumeUpButton.snp.remakeConstraints({(make) -> Void in
				make.centerY.equalTo(self.mpVolumeSlider)
				make.left.equalTo(self.mpVolumeSlider.snp.right).offset(10)
				make.width.height.equalTo(30)
			});



		} else if(self.device.isPad) {
			// TODO: Right now elements are positioned based on exact height calcutaions on iPhone but not on iPad, fix this
			self.screenHieght = isDevicePortrait() ? self.view.bounds.height / 2 : self.view.bounds.height;
			
			let artworkViewWidthHeight = isDevicePortrait() ? (self.screenWidth / 3 - 20) : (self.screenWidth / 2.5 - 20);
			self.containerView.addSubview(self.artworkView);
			self.artworkView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(0).offset(isDevicePortrait() ? 20 : 40)
				make.left.equalTo(0).offset(20)
				make.width.height.equalTo(artworkViewWidthHeight);
			});
			self.artworkView.image = artwork;
			self.artworkView.layoutIfNeeded();
			
			self.containerView.bringSubview(toFront: self.artworkView);
			
			let titlesContainer = UIView();
			self.containerView.addSubview(titlesContainer);
			titlesContainer.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(0).offset(20)
				make.left.equalTo(self.artworkView.snp.right).offset(20)
				make.right.equalTo(0).inset(20)
				make.height.equalTo(self.screenWidth / 3 - 20)
			});
			
			let titlesStackView = UIStackView(arrangedSubviews: [self.titleView, self.artistView]);
			titlesStackView.axis = .vertical;
			titlesStackView.alignment = .center;
			titlesStackView.distribution = .fillProportionally;
			titlesStackView.spacing = 10;
			titlesContainer.addSubview(titlesStackView);
			titlesStackView.snp.remakeConstraints ({(make) -> Void in
				make.centerX.centerY.equalToSuperview()
				make.right.left.equalTo(0)
			});
			
			self.containerView.addSubview(self.progressBarView)
			//progressBar.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
			self.progressBarView.snp.remakeConstraints ({(make) -> Void in
				//make.centerY.equalToSuperview().offset(-self.view.bounds.height / 5)
				make.top.equalTo(artworkView.snp.bottom).offset(/*50*/ 4 * self.screenHieght / 100)
				make.centerX.equalTo(self.view);
				make.width.equalTo(self.view.bounds.width - 30);
				make.height.equalTo(10)
			});
			
			self.containerView.addSubview(self.progressPassedView);
			self.progressPassedView.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(self.progressBarView.snp.bottom).offset(5)
				make.left.equalTo(0).offset(20)
			});
			
			self.containerView.addSubview(self.durationView);
			self.durationView.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(self.progressBarView.snp.bottom).offset(5)
				make.right.equalTo(0).inset(20)
			});
			
			let controlsStackView = UIStackView(arrangedSubviews: [self.shuffleButton, self.skipBackwardButton, self.playPauseStopButton, self.skipForwardButton, self.repeatButton])
			controlsStackView.axis = .horizontal;
			controlsStackView.distribution = .equalCentering;
			self.containerView.addSubview(controlsStackView);
			
			controlsStackView.snp.remakeConstraints ({(make) -> Void in
				make.top.equalTo(self.durationView.snp.bottom).offset(5 * self.screenHieght / 100)
				make.centerX.equalTo(self.view);
				make.width.equalTo(self.view.bounds.width / 2);
				make.height.equalTo(12.31 * self.screenHieght / 100);
			});
			
			self.containerView.addSubview(self.mpVolumeSlider);
			self.mpVolumeSlider.snp.remakeConstraints({(make) -> Void in
				make.top.equalTo(controlsStackView.snp.bottom).offset(/*20*/ 5 * self.screenHieght / 100)
				make.height.equalTo(50).priority(50)
				// see https://stackoverflow.com/questions/46520830/unable-to-simultaneously-satisfy-constraints-custom-header-section
				make.width.equalTo(self.containerView.frame.width / 1.8).priority(50) // priority fixes the bullshit errors about _UITemporaryLayout...
				make.centerX.equalTo(self.containerView)
			});
			
			self.containerView.addSubview(self.volumeDownButton);
			self.volumeDownButton.snp.remakeConstraints({(make) -> Void in
				make.centerY.equalTo(self.mpVolumeSlider)
				make.right.equalTo(self.mpVolumeSlider.snp.left)
				make.width.height.equalTo(30)
			});
			
			self.containerView.addSubview(self.volumeUpButton);
			self.volumeUpButton.snp.remakeConstraints({(make) -> Void in
				make.centerY.equalTo(self.mpVolumeSlider)
				make.left.equalTo(self.mpVolumeSlider.snp.right).offset(10)
				make.width.height.equalTo(30)
			});
		}
	}
	
//	func updateUIforColoredPlayer() {
//		if(Constants.COLORED_PLAYER) {
//			DispatchQueue.main.async {
//				if(self.artworkView.image != nil) {
////					self.view.backgroundColor = self.audioPlayer.currentItem?.colors?.backgroundColor;
//					self.titleView.textColor = self.audioPlayer.currentItem?.colors?.primaryColor;
//					self.artistView.textColor = self.audioPlayer.currentItem?.colors?.accentColor;
//					self.progressBarView.tintColor = self.audioPlayer.currentItem?.colors?.accentColor;
//					if(self.audioPlayer.mode.contains(.shuffle)) {
//						self.shuffleButton.setIcon(icon: .ionicons(.iosShuffleStrong), color: self.audioPlayer.currentItem!.colors!.primaryColor!);
//					} else {
//						self.shuffleButton.setIcon(icon: .ionicons(.iosShuffleStrong), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					}
//					self.skipBackwardButton.setIcon(icon: .ionicons(.iosReward), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					if(self.audioPlayer.state == .playing || self.audioPlayer.state == .buffering) {
//						self.playPauseStopButton.setIcon(icon: .ionicons(.pause), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					} else {
//						self.playPauseStopButton.setIcon(icon: .ionicons(.play), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					}
//					self.skipForwardButton.setIcon(icon: .ionicons(.iosFastforward), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					if(self.audioPlayer.mode.contains(.repeat)) {
//						self.repeatButton.setIcon(icon: .ionicons(.iosLoopStrong), color: self.audioPlayer.currentItem!.colors!.primaryColor!);
//					} else {
//						self.repeatButton.setIcon(icon: .ionicons(.iosLoopStrong), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					}
//					self.progressPassedView.textColor = self.audioPlayer.currentItem?.colors?.accentColor;
//					self.durationView.textColor = self.audioPlayer.currentItem?.colors?.accentColor;
//					self.volumeDownButton.setIcon(icon: .ionicons(.iosVolumeLow), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//					self.mpVolumeSlider.tintColor = self.audioPlayer.currentItem?.colors?.accentColor;
//					self.volumeUpButton.setIcon(icon: .ionicons(.iosVolumeHigh), color: self.audioPlayer.currentItem!.colors!.accentColor!);
//
//
//					let whiteAndAccentContrastRatio = UIColor.white.contrastRatio(with: self.audioPlayer.currentItem!.colors!.accentColor!);
//					let blackAndAccentContrastRatio = UIColor.black.contrastRatio(with: self.audioPlayer.currentItem!.colors!.accentColor!);
//
//					if(whiteAndAccentContrastRatio > blackAndAccentContrastRatio) {
//						// white is more suitable
//						self.progressBarView.maximumTrackTintColor = .white;
//						self.mpVolumeSlider.maximumTrackTintColor = .white;
//					} else {
//						// black is more suitable
//						self.progressBarView.maximumTrackTintColor = .black;
//						self.mpVolumeSlider.maximumTrackTintColor = .black;
//					}
//
//					if(self.backgroundBlurredImageView.image != nil) {
//						self.updateBackgroundForMusicPlayer();
//					} else {
//						self.setBackgroundForMusicPlayer();
//					}
//				}
//			}
//		}
//	}
	
	func setBackgroundForMusicPlayer() {
		if(!self.device.isPad || !isDeviceLandscape()) {
			// there's a bug in iPad landscape so don't do this for that specific case
			self.backgroundBlurredImageView.contentMode = .scaleAspectFill;
		}
		self.backgroundBlurredImageView.image = self.artworkView.image!;
		
		// the order is important, the image must be placed before the blurEffect view
		self.view.insertSubview(self.backgroundBlurredImageView, at: 0);
		
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark);
		let blurEffectView = UIVisualEffectView(effect: blurEffect);
		blurEffectView.frame = self.backgroundBlurredImageView.frame;
		
		self.view.insertSubview(blurEffectView, at: 1);
	}
	
	func updateBackgroundForMusicPlayer() {
		if(self.artworkView.image != nil) {
			backgroundBlurredImageView.image = self.artworkView.image!;
		}
	}
	
	@objc
	func onStopAndClearPlayers(_ notification: Notification) {
		self.dismiss(animated: true, completion: nil);
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true);
		
		if(self.chevronDownIcon != nil) {
			self.hideAndShowDropDownIcon();
		}

//		self.becomeFirstResponder();

//		let animator = ChainableAnimator(view: self.artworkView)
//		animator.make(scale: 1.1).animate(t: 3.0)

//		applyArtworkFilter(inputImage: artwork!, effectPower: 11) { (image) in
//			self.artworkViewBackground.image = image;
//
//			self.containerView.bringSubview(toFront: self.artworkView);
////
////			let animator = ChainableAnimator(view: self.artworkView)
////			animator.make(scale: 1.1).animate(t: 3.0)
////
////			let animator2 = ChainableAnimator(view: self.artworkViewBackground);
////			animator2.make(alpha: 1.0).animate(t: 4.0)
//		}
	}
	
	func hideAndShowDropDownIcon() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			UIView.animate(withDuration: 0.5, animations: {
				self.chevronDownIcon?.snp.remakeConstraints({(make) -> Void in
					make.left.equalTo(10)
					make.top.equalTo(30)
					make.width.height.equalTo(30)
				});
				self.chevronDownIcon?.layoutIfNeeded();
				self.view.layoutIfNeeded();
			}) { (completed) in
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					UIView.animate(withDuration: 0.3, animations: {
						self.chevronDownIcon?.snp.remakeConstraints({(make) -> Void in
							make.left.equalTo(10)
							make.top.equalTo(10)
							make.width.height.equalTo(30)
						});
						self.chevronDownIcon?.alpha = 0;
						self.chevronDownIcon?.layoutIfNeeded();
						self.view.layoutIfNeeded();
					}) { (completed) in
						
					}
				}
			}
		}
	}
	
	@objc
	func shuffleButtonPressed() {
		let animator = CoreAnimator(view: self.shuffleButton);
		animator.rotateX(angle: 180).animate(t: 0.3);
		if(self.audioPlayer.mode.contains(AudioPlayerMode.shuffle) == true) {
			self.audioPlayer.mode.remove(AudioPlayerMode.shuffle);
			self.shuffleButton.setIcon(icon: .ionicons(.iosShuffleStrong), color: self.audioPlayer.currentItem!.colors.accentColor);
		} else {
			self.audioPlayer.mode.insert(AudioPlayerMode.shuffle);
			self.shuffleButton.setIcon(icon: .ionicons(.iosShuffleStrong), color: self.audioPlayer.currentItem!.colors.primaryColor);
		}
	}
	
	@objc
	func skipBackwardButtonPressed() {
		self.audioPlayer.previous();
	}
	
	@objc
	func playButtonPressed() {
		// button icon changes with the state change, no need to do it here
		if(self.audioPlayer.state == AudioPlayerState.paused) {
			self.audioPlayer.resume();
		} else if(self.audioPlayer.state == AudioPlayerState.playing || self.audioPlayer.state == AudioPlayerState.buffering) {
			self.audioPlayer.pause();
		}
	}
	
	@objc
	func skipForwardButtonPressed() {
		self.audioPlayer.nextOrStop();
	}
	
	@objc
	func repeatButtonPressed() {
		let animator = CoreAnimator(view: self.repeatButton);
		animator.rotate(angle: 360).animate(t: 0.3);
		if(self.audioPlayer.mode.contains(AudioPlayerMode.repeat) == true) {
			self.audioPlayer.mode.remove(AudioPlayerMode.repeat);
			self.repeatButton.setIcon(icon: .ionicons(.iosLoopStrong), color: self.audioPlayer.currentItem!.colors.accentColor);
		} else {
			self.audioPlayer.mode.insert(AudioPlayerMode.repeat);
			self.repeatButton.setIcon(icon: .ionicons(.iosLoopStrong), color: self.audioPlayer.currentItem!.colors.primaryColor);
		}
	}
	
	@objc
	func closeModalButtonPressed() {
		self.dismiss(animated: true, completion: nil);
	}
	
	@objc
	func onProgressBarValueChanged(slider: MDCSlider, event: UIEvent) {
		let value = slider.value;
		let alreadyPaused = self.audioPlayer.state == .paused ? true : false;
		
		// pause the player to avoid ui glitches
		self.audioPlayer.pause();
		
		// the value coming from the slider is in percentage, convert it to seconds according to the item duration
		let time = Int(value * CGFloat(self.audioPlayer.currentItemDuration ?? 0) / 100);
		
		self.audioPlayer.seek(to: TimeInterval(time));
		if(!alreadyPaused) {
			self.audioPlayer.resume();
		}
	}
	
	private func applyArtworkFilter(inputImage: UIImage, effectPower: Int, handler: @escaping (UIImage) -> Void) {
		// convert UIImage to CIImage
		let inputCIImage = CIImage(image: inputImage)!
		
		// Create Blur CIFilter, and set the input image
		let blurFilter = CIFilter(name: "CIGaussianBlur")!
		blurFilter.setValue(inputCIImage, forKey: kCIInputImageKey)
		blurFilter.setValue(effectPower, forKey: kCIInputRadiusKey)
		
		handler(UIImage(ciImage: blurFilter.outputImage!));
	}
	
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		let touch = touches.first
//		print(self.view.bounds.height)
//		print(UIApplication.shared.keyWindow?.bounds.height)
//		guard let location = touch?.location(in: UIApplication.shared.keyWindow) else { return }
//		if self.view.frame.contains(location) {
//			print("Tapped inside the view")
//		}
//	}
}

extension MusicPlayerViewController {
	
	func setupCurrentAudioItemImage() {
		self.currentItemImage.asObservable()
			.subscribe(onNext: { currentItemImage in
				if(currentItemImage == nil) {
					return;
				}
				
				self.artworkView.image = currentItemImage;

				let whiteAndAccentContrastRatio = UIColor.white.contrastRatio(with: self.audioPlayer.currentItem!.colors.accentColor);
				let blackAndAccentContrastRatio = UIColor.black.contrastRatio(with: self.audioPlayer.currentItem!.colors.accentColor);

				if(whiteAndAccentContrastRatio > blackAndAccentContrastRatio) {
					// white is more suitable
//					self.progressBarView.maximumTrackTintColor = .white;
					self.mpVolumeSlider.maximumTrackTintColor = UIColor.white;
				} else {
					// black is more suitable
//					self.progressBarView.maximumTrackTintColor = .black;
					self.mpVolumeSlider.maximumTrackTintColor = UIColor.black;
				}

				if(Constants.COLORED_PLAYER) {
					if(self.backgroundBlurredImageView.image != nil) {
						self.updateBackgroundForMusicPlayer();
					} else {
						self.setBackgroundForMusicPlayer();
					}
				}
			})
			.disposed(by: self.disposeBag);
	}
	
	func setupAudioPlayerStateObserver() {
		self.audioPlayerState.observeOn(MainScheduler.instance)
			.subscribeOn(MainScheduler.instance)
			.asObservable()
			.subscribe(onNext: { audioPlayerState in
				
				if(audioPlayerState == AudioPlayerState.paused) {
					self.playPauseStopButton.setIcon(icon: .ionicons(.play), color: self.audioPlayer.currentItem!.colors.accentColor);
				} else if(audioPlayerState == AudioPlayerState.playing) {
					self.playPauseStopButton.setIcon(icon: .ionicons(.pause), color: self.audioPlayer.currentItem!.colors.accentColor);
				}
				
			})
			.disposed(by: self.disposeBag);
	}
	
	func setupCurrentAudioItemObserver() {
		self.currentItem.observeOn(MainScheduler.instance)
			.subscribeOn(MainScheduler.instance)
			.asObservable()
			.subscribe(onNext: { currentItem in
				
				if(currentItem == nil) {
					return;
				}
				
				self.titleView.text = currentItem!.title;
				self.artistView.text = currentItem!.artist;
				
				self.loadImageToArtworkViewAndPlayableItem(imageUrl: currentItem!.imageUrl);
				
				self.progressBarView.value = 0;
				self.progressPassedView.text = format(duration: self.audioPlayer.currentItemProgression ?? 0);
				self.durationView.text = format(duration: self.audioPlayer.currentItemDuration ?? 0);
				
				self.chevronDownIcon?.setIcon(color: currentItem!.colors.accentColor, forState: .normal);
				
				if(currentItem!.imageUrl != nil) {
					self.setupCurrentAudioItemImage(imageUrl: currentItem!.imageUrl!);
				}
				
				self.setupColorsForUIElements(currentItem: currentItem!);
				
			})
			.disposed(by: self.disposeBag);
	}
	
	func setupCurrentAudioItemProgressionObserver() {
		self.currentItemProgression.observeOn(MainScheduler.instance)
			.subscribeOn(MainScheduler.instance)
			.asObservable()
			.subscribe(onNext: { currentItemProgression in
				if(currentItemProgression == nil) {
					return;
				}
				
				let itemDuration = self.currentItemDuration.value ?? 0;
				
				self.currentItemDuration.accept(self.audioPlayer.currentItemDuration);
				
				let percentage = (itemDuration > 0 ? CGFloat(currentItemProgression! / itemDuration) * 100 : 0);
				self.progressPassedView.text = format(duration: currentItemProgression!);
				
				if(percentage > 0.0 && !self.progressBarView.isTracking) {
					self.progressBarView.value = percentage;
				}
			})
			.disposed(by: self.disposeBag);
	}
	
	func setupCurrentAudioItemDurationObserver() {
		self.currentItemDuration.observeOn(MainScheduler.instance)
			.subscribeOn(MainScheduler.instance)
			.asObservable()
			.subscribe(onNext: { currentItemDuration in
				if(currentItemDuration == nil) {
					return;
				}
				
				self.durationView.text = format(duration: currentItemDuration!);
			})
			.disposed(by: self.disposeBag);
	}
	
	func setupCurrentAudioItemImage(imageUrl: String) {
		KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL.createFrom(localOrRemoteAddress: imageUrl)), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) -> () in
			self.currentItemImage.accept(image);
		};
	}
	
	func setupColorsForUIElements(currentItem: PlayableItem) {
		self.titleView.textColor = currentItem.colors.primaryColor;
		self.artistView.textColor = currentItem.colors.accentColor;
		self.progressBarView.color = currentItem.colors.accentColor;
		if(self.audioPlayer.mode.contains(AudioPlayerMode.shuffle) == true) {
			self.shuffleButton.setIcon(icon: .ionicons(.iosShuffleStrong), color: currentItem.colors.primaryColor);
		} else {
			self.shuffleButton.setIcon(icon: .ionicons(.iosShuffleStrong), color: currentItem.colors.accentColor);
		}
		self.skipBackwardButton.setIcon(icon: .ionicons(.iosRewind), color: currentItem.colors.accentColor);
		if(self.audioPlayer.state == AudioPlayerState.playing || self.audioPlayer.state == AudioPlayerState.buffering) {
			self.playPauseStopButton.setIcon(icon: .ionicons(.pause), color: currentItem.colors.accentColor);
		} else {
			self.playPauseStopButton.setIcon(icon: .ionicons(.play), color: currentItem.colors.accentColor);
		}
		self.skipForwardButton.setIcon(icon: .ionicons(.iosFastforward), color: currentItem.colors.accentColor);
		if(self.audioPlayer.mode.contains(AudioPlayerMode.repeat) == true) {
			self.repeatButton.setIcon(icon: .ionicons(.iosLoopStrong), color: currentItem.colors.primaryColor);
		} else {
			self.repeatButton.setIcon(icon: .ionicons(.iosLoopStrong), color: currentItem.colors.accentColor);
		}
		self.progressPassedView.textColor = currentItem.colors.accentColor;
		self.durationView.textColor = currentItem.colors.accentColor;
		self.volumeDownButton.setIcon(icon: .ionicons(.iosVolumeLow), color: currentItem.colors.accentColor);
		self.mpVolumeSlider.tintColor = currentItem.colors.accentColor;
		self.volumeUpButton.setIcon(icon: .ionicons(.iosVolumeHigh), color: currentItem.colors.accentColor);
	}
	
}




