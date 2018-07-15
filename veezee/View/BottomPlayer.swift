//
//  BottomPlayer.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/23/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel
import DeviceKit
import Kingfisher

protocol BottomPlayerDelegate: class {
	func bottomPlayerTapped();
}

class BottomPlayer: UIView {
	
	static let Height: CGFloat = 60.0;
	
	weak var delegate: BottomPlayerDelegate?;
	
	var device = Device();
	var audioPlayer = AudioPlayer.shared;
	
	var backgroundImageView: UIImageView?;
	
	lazy var artworkView: UIImageView = {
		let artworkView = UIImageView();
		let bannerImage = UIImage(named: "artwork")!;
		artworkView.image = bannerImage;
		artworkView.contentMode = .scaleAspectFit;
		artworkView.clipsToBounds = true;
		artworkView.layer.cornerRadius = 4;
		
		return artworkView;
	}();
	
	lazy var titleView: UILabel = {
		let titleView = MarqueeLabel.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), duration: 10.0, fadeLength: 10.0);
		titleView.trailingBuffer = 40;
		titleView.animationDelay = 3;
		titleView.textColor = self.audioPlayer.currentItem?.colors?.primaryColor;
		titleView.font = titleView.font.withSize(self.device.isPad ? 20 : 16);
		
		return titleView;
	}();
	
	lazy var artistView: UILabel = {
		let artistView = UILabel();
		artistView.textColor = self.audioPlayer.currentItem?.colors?.accentColor;
		artistView.font = artistView.font.withSize(self.device.isPad ? 15 : 12);
		
		return artistView;
	}();
	
	lazy var playPauseButtonView: IconedButton = {
		let playPauseButtonView = IconedButton();
		playPauseButtonView.initButton(icon: .ionicons(.pause), iconSize: 30, color: self.audioPlayer.currentItem == nil ? UIColor.black : self.audioPlayer.currentItem!.colors!.accentColor!, forState: .normal);
		playPauseButtonView.addTarget(self, action: #selector(self.toggleMusicPlayerPlayStatus), for: .touchUpInside);
		
		return playPauseButtonView;
	}();
	
	override init(frame: CGRect) {
		super.init(frame: frame);
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerWillStartPlaying(_:)), name: Notification.Name(rawValue: AudioPlayer.Notifications.willStartPlayingItem), object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(self.audioPlayerDidChangeState(_:)), name: Notification.Name(rawValue: AudioPlayer.Notifications.didChangeState), object: nil);
		
		let panGestureRecognizer = UIPanGestureRecognizer(target:self, action: #selector(self.handlePan(sender:)));
		self.addGestureRecognizer(panGestureRecognizer);
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)));
		self.addGestureRecognizer(tap);
	}
	
	func setLayouts() {
		if(self.audioPlayer.state == AudioPlayerState.fsAudioStreamPlaying || self.audioPlayer.state == AudioPlayerState.fsAudioStreamBuffering || self.audioPlayer.state == AudioPlayerState.fsAudioStreamPaused) {
			self.isHidden = false;
		} else {
			self.isHidden = true;
		}
		
		if(!Constants.COLORED_PLAYER) {
			let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark);
			let blurEffectView = UIVisualEffectView(effect: blurEffect);
			blurEffectView.frame = CGRect(x: 0, y: 0, width: (self.bounds.width), height: BottomPlayer.Height);
			blurEffectView.translatesAutoresizingMaskIntoConstraints = false;
			self.addSubviewOnce(blurEffectView);
		} else {
			self.backgroundImageView = UIImageView();
			self.backgroundImageView!.frame = CGRect(x: 0, y: 0, width: (self.bounds.width), height: BottomPlayer.Height);
			self.backgroundImageView!.contentMode = .redraw;
			
			// the order is important, the image must be placed before the blurEffect view
			self.insertSubview(self.backgroundImageView!, at: 0);
			
			let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark);
			let blurEffectView = UIVisualEffectView(effect: blurEffect);
			blurEffectView.frame = self.backgroundImageView!.frame;
			
			self.insertSubview(blurEffectView, at: 1);
		}
		
		self.addSubviewOnce(self.artworkView);
		artworkView.snp.remakeConstraints({(make) -> Void in
			make.width.height.equalTo(70)
			make.bottom.equalTo(0).inset(10)
			make.left.equalTo(20)
		});
		
		let titlesStackView = UIStackView(arrangedSubviews: [titleView, artistView]);
		titlesStackView.axis = .vertical;
		titlesStackView.distribution = .fill;
		self.addSubviewOnce(titlesStackView);
		titlesStackView.snp.remakeConstraints ({(make) -> Void in
			make.centerY.equalToSuperview()
			make.left.equalTo(artworkView.snp.right).offset(20)
			make.right.equalTo(0).inset(50)
		});
		
		self.addSubviewOnce(playPauseButtonView);
		playPauseButtonView.snp.remakeConstraints ({(make) -> Void in
			make.centerY.equalToSuperview()
			make.right.equalTo(0).inset(20)
		});
		
		self.updateUI();
	}
	
	var centerLocation = CGPoint.zero;
	var startLocation = CGPoint.zero;
	var stopLocation = CGPoint.zero;
	@objc
	func handlePan(sender: UIPanGestureRecognizer) {
		UIView.animate(withDuration: 0.2) {
			if(sender.state == .began) {
				self.centerLocation = (sender.view?.center)!;
				self.startLocation = sender.location(in: sender.view);
			} else if(sender.state == .changed) {
				guard let isLeft = sender.isLeft(view: sender.view!), let isUp = sender.isUp(view: sender.view!) else {
					return;
				}
				if(isLeft) {
					var center = sender.view?.center;
					let translation = sender.translation(in: sender.view);
					center = CGPoint(x: center!.x + translation.x, y: center!.y);
					sender.view?.center = center!;
					sender.setTranslation(CGPoint.zero, in: sender.view);
				} else if(isUp) {
					self.handleTap(sender: nil);
					sender.view?.center = self.centerLocation;
					sender.setTranslation(CGPoint.zero, in: sender.view);
				}
			} else if(sender.state == .ended) {
				if((sender.view?.frame.origin.x)! * -1 < CGFloat(200.0)) {
					sender.view?.center = self.centerLocation;
					sender.setTranslation(CGPoint.zero, in: sender.view);
				} else {
					// passed the limit, hide the bottom player and stop the music
					sender.view?.frame.origin.x -= self.bounds.size.width;
					// self.audioPlayer.pause();
					DispatchQueue.global(qos: .background).async {
						self.audioPlayer.stop();
					}
				}
			}
		}
	}
	
	@objc
	func handleTap(sender: UITapGestureRecognizer?) {
		self.delegate?.bottomPlayerTapped();
	}
	
	@objc
	func toggleMusicPlayerPlayStatus() {
		DispatchQueue.main.async {
			if(self.audioPlayer.state == AudioPlayerState.fsAudioStreamPlaying || self.audioPlayer.state == AudioPlayerState.fsAudioStreamBuffering) {
				self.audioPlayer.pause();
			} else if(self.audioPlayer.state == AudioPlayerState.fsAudioStreamPaused) {
				self.audioPlayer.resume();
			}
			self.resetVisibility();
		}
	}
	
	func resetVisibility() {
		DispatchQueue.main.async {
			
			if(self.audioPlayer.state == AudioPlayerState.fsAudioStreamPlaying || self.audioPlayer.state == AudioPlayerState.fsAudioStreamBuffering) {
				self.superview?.bringSubview(toFront: self);
				self.isHidden = false;
			} else if(self.audioPlayer.state == AudioPlayerState.fsAudioStreamPaused) {
				self.superview?.bringSubview(toFront: self);
				self.isHidden = false;
			} else {
				self.isHidden = true;
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

extension BottomPlayer {
	
	func updateUI() {
		DispatchQueue.main.async {
			self.titleView.text = self.audioPlayer.currentItem?.title;
			self.titleView.textColor = self.audioPlayer.currentItem?.colors?.primaryColor;
			
			self.artistView.text = self.audioPlayer.currentItem?.artist;
			self.artistView.textColor = self.audioPlayer.currentItem?.colors?.accentColor;
			
			if(self.audioPlayer.currentItem?.imageUrl != nil) {
				self.artworkView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: self.audioPlayer.currentItem!.imageUrl!));
				self.backgroundImageView?.kf.setImage(with: URL.createFrom(localOrRemoteAddress: self.audioPlayer.currentItem!.imageUrl!));
			} else {
				self.artworkView.image = UIImage(named: "artwork");
			}
			
			if(self.audioPlayer.currentItem?.colors != nil) {
				self.isHidden = false;
				if(self.audioPlayer.state == AudioPlayerState.fsAudioStreamBuffering || self.audioPlayer.state == AudioPlayerState.fsAudioStreamPlaying) {
					self.playPauseButtonView.setIcon(icon: .ionicons(.pause), color: self.audioPlayer.currentItem!.colors!.accentColor!);
				} else {
					self.playPauseButtonView.setIcon(icon: .ionicons(.play), color: self.audioPlayer.currentItem!.colors!.accentColor!);
				}
			}
		}
		self.resetVisibility();
	}
	
	@objc
	func audioPlayerWillStartPlaying(_ notification: Notification) {
		self.updateUI();
	}
	
	@objc
	func audioPlayerDidChangeState(_ notification: Notification) {
		self.updateUI();
	}
	
}
