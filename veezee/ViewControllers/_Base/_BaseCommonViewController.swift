//
//  BaseViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/28/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import UIKit
import MediaPlayer
import KeychainSwift
import PMAlertController
import DeviceKit
import Sheeeeeeeeet
import Kingfisher

class _BaseCommonViewController: UIViewController, UserPlaylistsDelegate {
	
	let device = Device();
	let keychain = KeychainSwift();
	
	let audioPlayer = AudioPlayer.shared;
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR ? .default : .lightContent;
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		self.registerSettingsBundle();
		NotificationCenter.default.addObserver(self, selector: #selector(self.appSettingsBundleChanged), name: UserDefaults.didChangeNotification, object: nil);
		// just for initialization this time
		self.appSettingsBundleChanged();
		
		if(!Constants.GUEST_MODE) {
			self.checkUserLogin();
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated);
	}
	
	func checkUserLogin() {
		func validateLoginWithDelayInBackground() {
			DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.5) {
				API.Account.validateLogin(token: self.keychain.get("token")) { (user, errorMessage, errorCode) in
					if(user == nil || (user?.name == nil || user?.email == nil)) {
						// error, user not authenticated
						self.keychain.clear();
						self.showLoginRequiredPage();
					} else {
						self.keychain.set(user!.name!, forKey: "name", withAccess: .accessibleAfterFirstUnlock);
						self.keychain.set(user!.email!, forKey: "email", withAccess: .accessibleAfterFirstUnlock);
						self.keychain.set(user!.expiresIn!.toDateTimeString(), forKey: "expiresIn", withAccess: .accessibleAfterFirstUnlock);
						self.keychain.set(user!.access!.expiresIn!.toDateTimeString(), forKey: "accessExpiresIn", withAccess: .accessibleAfterFirstUnlock);
						// update the expiration session date
						AppDelegate.autoLoginSessionExpireDate = getDateTimeForMinutesInTheFuture(minutes: 15);
					}
				}
			}
		}
		
		let reachability = Reachability();
		if(AppDelegate.autoLoginSessionExpireDate < Date()) {
			// session expired
			
			if(self.keychain.get("token") != nil) {
				if(reachability.isReachable()) {
					// validate user login, pass the current token to the server
					validateLoginWithDelayInBackground();
				}
			} else {
				// log out the user
				self.keychain.clear();
				self.showLoginRequiredPage();
			}
		}
	}
	
	static var AlreadyShownLoginRequiredPage = false;
	func showLoginRequiredPage() {
		if(_BaseCommonViewController.AlreadyShownLoginRequiredPage) {
			return;
		}
		let loginRequiredMessageVC = LoginRequiredMessageViewController();
		self.present(loginRequiredMessageVC, animated: true, completion: nil);
		let errorAC = PMAlertController(title: "Error", description: "Your login is expired.\nYou must log in again.", image: nil, style: .alert);
		errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
		errorAC.addAction(PMAlertAction(title: "Log in", style: .default, action: {
			UIView.transition(with: (UIApplication.shared.delegate?.window!)!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
				UIApplication.shared.delegate?.window!?.rootViewController = LoginRegisterContainerViewController();
			});
			_BaseCommonViewController.AlreadyShownLoginRequiredPage = false;
		}));
		errorAC.show();
		_BaseCommonViewController.AlreadyShownLoginRequiredPage = true;
	}
	
	func showTrackActionSheet(track: Track) {
		let headerView = UIView();
		
		var actionSheetItems = [ActionSheetItem]();
		
		if(!Constants.GUEST_MODE) {
			let addToPlaylistButton = ActionSheetCustomButton(title: "Add to a Playlist...", value: "Add to a Playlist...");
			addToPlaylistButton.tapBehavior = .none;
			
			actionSheetItems.append(addToPlaylistButton);
		}
		
		let cancelButton = ActionSheetCancelButton(title: "Cancel");
		actionSheetItems.append(cancelButton);
		
		var actionSheet: UniversalActionSheet;
		actionSheet = UniversalActionSheet(items: actionSheetItems) { (_, item) in
			guard let value = item.value as? String else { return }
			
			if(value == "Add to a Playlist...") {
				let modal = UserPlaylistsViewController(trackToAddToPlaylist: track);
				let transitionDelegate = DeckTransitioningDelegate();
				modal.transitioningDelegate = transitionDelegate;
				modal.modalPresentationStyle = UIModalPresentationStyle.custom;
				modal.delegate = self;
				
				self.present(modal, animated: true, completion: nil);
			}
		}
		
		actionSheet.sheet?.headerView = headerView;
		headerView.snp.makeConstraints ({ (make) in
			make.left.right.equalTo(0)
			make.height.equalTo(130)
		});
		headerView.layoutIfNeeded();
		
		let albumArtView = UIImageView();
		albumArtView.contentMode = .scaleAspectFit;
		albumArtView.image = UIImage(named: "artwork");
		
		headerView.addSubview(albumArtView);
		albumArtView.snp.makeConstraints ({ (make) in
			make.left.equalTo(0)
			make.width.equalTo(130)
			make.top.bottom.equalTo(0)
		});
		
		if(track.image != nil) {
			KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL.createFrom(localOrRemoteAddress: track.image!)), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) -> () in
				albumArtView.image = image;
			};
			
			let backgroundBlurredImageView = UIImageView();
			backgroundBlurredImageView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: 130);
			backgroundBlurredImageView.contentMode = .redraw;
			backgroundBlurredImageView.image = albumArtView.image!;
			
			// the order is important, the image must be placed before the blurEffect view
			headerView.insertSubview(backgroundBlurredImageView, at: 0);
			
			let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark);
			let blurEffectView = UIVisualEffectView(effect: blurEffect);
			blurEffectView.frame = backgroundBlurredImageView.frame;
			
			headerView.insertSubview(blurEffectView, at: 1);
		}
		
		let shareButton = UIButton();
		shareButton.setIcon(icon: .ionicons(.iosUpload), iconSize: 27, color: .white, forState: .normal);
		
		headerView.addSubview(shareButton);
		shareButton.snp.makeConstraints ({ (make) in
			make.left.equalTo(albumArtView.snp.right).offset(10)
			make.bottom.equalTo(0).inset(5)
		});
		
		let rightArrowButton = UIButton();
		rightArrowButton.setIcon(icon: .ionicons(.iosArrowRight), iconSize: 27, color: .white, forState: .normal);
		
		headerView.addSubview(rightArrowButton);
		rightArrowButton.snp.makeConstraints ({ (make) in
			make.right.equalTo(0).inset(5)
			make.centerY.equalToSuperview()
		});
		
		let titleView = UILabel();
		titleView.text = track.title;
		titleView.textColor = .white;
		titleView.font = UIFont.systemFont(ofSize: 17, weight: .bold);
		
		let albumView = UILabel();
		albumView.text = track.album!.title;
		albumView.textColor = .white;
		albumView.font = UIFont.systemFont(ofSize: 16, weight: .regular);
		
		let artistView = UILabel();
		artistView.text = track.album!.artist!.name;
		artistView.textColor = .lightGray;
		artistView.font = UIFont.systemFont(ofSize: 15, weight: .regular);
		
		headerView.addSubview(titleView);
		titleView.snp.makeConstraints ({ (make) in
			make.left.equalTo(albumArtView.snp.right).offset(10)
			make.right.equalTo(0).inset(10)
			make.top.equalTo(10)
		});
		
		headerView.addSubview(albumView);
		albumView.snp.makeConstraints ({ (make) in
			make.left.equalTo(albumArtView.snp.right).offset(10)
			make.right.equalTo(0).inset(30)
			make.top.equalTo(titleView.snp.bottom).offset(5)
		});
		
		headerView.addSubview(artistView);
		artistView.snp.makeConstraints ({ (make) in
			make.left.equalTo(albumArtView.snp.right).offset(10)
			make.right.equalTo(0).inset(30)
			make.top.equalTo(albumView.snp.bottom).offset(5)
		});
		
		actionSheet.sheet?.presenter = ActionSheetDefaultPresenter();
		actionSheet.sheet?.present(in: self, from: self.view);
	}
	
	func registerSettingsBundle() {
		let appDefaults = [String:AnyObject]();
		UserDefaults.standard.register(defaults: appDefaults);
	}
	
	@objc
	func appSettingsBundleChanged() {
		SettingsBundleHelper.appSettingsBundleChanged();
	}
}

extension _BaseCommonViewController {
	
	func playlistSelected(playlist: Album) {
		print(playlist.title)
	}
	
	func trackAddedToPlaylist(playlist: Album) {
		print(playlist.title)
	}
	
}

extension UINavigationController {
	// this makes the preferredStatusBar... functions work when using a UINavigationController and UITabbar
	// without it, they won't work
	override open var childViewControllerForStatusBarStyle: UIViewController? {
		return self.topViewController;
	}
}
