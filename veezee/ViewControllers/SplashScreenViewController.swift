//
//  SplashScreenViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/26/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import Kingfisher
import NVActivityIndicatorView

class SplashScreenViewController: UIViewController {
	let keychain = KeychainSwift();
	lazy var token: String? = self.keychain.get("token");
	lazy var tokenExpiresIn: String? = self.keychain.get("expiresIn");
	
	lazy var logoView: UIImageView = {
		let logoView = UIImageView();
		logoView.image = UIImage(named: "logo-basic-white");
		logoView.contentMode = .scaleAspectFit;
		logoView.layer.zPosition = 8;
		
		return logoView;
	}();
	
	lazy var autoLoginActivityIndicator: NVActivityIndicatorView = {
		let autoLoginActivityIndicator = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white);
		autoLoginActivityIndicator.layer.zPosition = 8;
		
		return autoLoginActivityIndicator;
	}();
	
	lazy var retryAutoLoginButton: LGButton = {
		let retryAutoLoginButton = LGButton();
		retryAutoLoginButton.titleString = "Retry";
		retryAutoLoginButton.titleFontSize = 18;
		retryAutoLoginButton.titleColor = .white;
		retryAutoLoginButton.cornersRadius = 4;
		retryAutoLoginButton.bgColor = Constants.ACCENT_COLOR;
		retryAutoLoginButton.shadowRadius = 4;
		retryAutoLoginButton.shadowOpacity = 2;
		retryAutoLoginButton.shadowOffset = CGSize(width: 0, height: 1);
		retryAutoLoginButton.shadowColor = Constants.ACCENT_COLOR;
		retryAutoLoginButton.layer.zPosition = 8;
		retryAutoLoginButton.addTarget(self, action: #selector(SplashScreenViewController.tryAutoLogin), for: .touchUpInside);
		
		return retryAutoLoginButton;
	}();
	
	lazy var offlineModeButton: LGButton = {
		let offlineModeButton = LGButton();
		offlineModeButton.titleString = "Offline Mode";
		offlineModeButton.titleFontSize = 18;
		offlineModeButton.titleColor = .white;
		offlineModeButton.cornersRadius = 4;
		offlineModeButton.bgColor = Constants.ACCENT_COLOR;
		offlineModeButton.shadowRadius = 4;
		offlineModeButton.shadowOpacity = 2;
		offlineModeButton.shadowOffset = CGSize(width: 0, height: 1);
		offlineModeButton.shadowColor = Constants.ACCENT_COLOR;
		offlineModeButton.layer.zPosition = 8;
		offlineModeButton.addTarget(self, action: #selector(SplashScreenViewController.replaceCurrentPageWithMainViews), for: .touchUpInside);
		
		return offlineModeButton;
	}();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		// Hide the status bar as this page should be full screen
		UIApplication.shared.isStatusBarHidden = true;
		
		self.view.backgroundColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		let pageOverlay = UIView();
		self.view.addSubview(pageOverlay);
		pageOverlay.snp.makeConstraints ({(make) in
			make.width.height.equalTo(self.view)
			make.top.bottom.equalTo(0)
		});
		pageOverlay.layer.zPosition = 2;
		pageOverlay.backgroundColor = .black;

		self.view.addSubview(self.logoView);
		self.logoView.snp.makeConstraints({(make) -> Void in
			make.centerX.centerY.equalTo(self.view)
			make.width.lessThanOrEqualTo(self.view.frame.width / 2)
			make.height.lessThanOrEqualTo((self.view.frame.width / 2) / 1.5)
		});
		self.logoView.layoutIfNeeded();
		
		self.view.addSubview(self.autoLoginActivityIndicator);
		autoLoginActivityIndicator.snp.makeConstraints({(make) -> Void in
			make.bottom.equalTo(0).inset(logoView.frame.height / 2)
			make.centerX.equalToSuperview()
			make.width.height.equalTo(logoView.frame.height / 5)
		});
		
		self.view.addSubview(self.retryAutoLoginButton);
		self.retryAutoLoginButton.snp.makeConstraints({(make) -> Void in
			make.center.equalTo(autoLoginActivityIndicator)
			make.width.equalTo(logoView.frame.width / 3)
		});
		self.retryAutoLoginButton.alpha = 0;
		self.retryAutoLoginButton.layoutIfNeeded();
		
		self.view.addSubview(self.offlineModeButton);
		self.offlineModeButton.snp.makeConstraints({(make) -> Void in
			make.center.equalTo(autoLoginActivityIndicator)
			make.width.equalTo(logoView.frame.width / 3)
		});
		self.offlineModeButton.alpha = 0;
		self.offlineModeButton.layoutIfNeeded();
		
		self.hideAndShowViewWithAnimation(logoView: logoView, animationDuration: 0.5, delayDuration: 0.3, completion: {
			let reachability = Reachability();
			
			if(Constants.GUEST_MODE || Constants.FORCE_OFFLINE_USAGE) {
				self.replaceCurrentPageWithMainViews();
				return;
			}
			
			if(self.token == nil || self.tokenExpiresIn == nil) {
				// token is not available, redirect to login page
				self.preloadLoginPageImagesAndGoToLoginPage();
			} else {
				// check for internet connectivity
				if(reachability.isReachable()) {
					// user is online, try to auto-login
					self.tryAutoLogin();
				} else {
					// user is offline, check the stored token expiration date
					if(self.isOfflineModeIsAvailable()) {
						// redirect to the main page
						self.replaceCurrentPageWithMainViews();
					} else {
						// token is expired, log the user out and redirect to the login page
						self.keychain.clear();
						self.autoLoginActivityIndicator.removeFromSuperview();
						UIApplication.shared.delegate?.window!?.rootViewController = LoginRegisterContainerViewController();
					}
				}
			}
		});
	}
	
	@objc
	func preloadLoginPageImagesAndGoToLoginPage() {
		autoLoginActivityIndicator.startAnimating();
		API.Lists.latestAlbumArts(handler: { (imagesList, errorMessage) in
			
			let urls = imagesList.map { URL(string: $0)! }
			let prefetcher = ImagePrefetcher(urls: urls) { skippedResources, failedResources, completedResources in
				self.autoLoginActivityIndicator.stopAnimating();
				self.keychain.clear();
				self.autoLoginActivityIndicator.removeFromSuperview();
				UIApplication.shared.delegate?.window!?.rootViewController = LoginRegisterContainerViewController(imagesList: imagesList);
			}
			prefetcher.start();
			
		});
	}
	
	var alreadyFailedOnce = false;
	@objc
	func tryAutoLogin() {
		self.retryAutoLoginButton.alpha = 0;
		autoLoginActivityIndicator.startAnimating();
		API.Account.validateLogin(token: self.keychain.get("token")) { (user, errorMessage, retryPossible) in
			self.autoLoginActivityIndicator.stopAnimating();

			if(retryPossible == nil) {
				// update the expiration session date
				AppDelegate.autoLoginSessionExpireDate = getDateTimeForHoursInTheFuture(hours: 6);
				self.keychain.set(user!.name!, forKey: "name");
				self.keychain.set(user!.email!, forKey: "email");
				
				self.autoLoginActivityIndicator.removeFromSuperview();
				
				self.replaceCurrentPageWithMainViews();
				return;
			} else {
				if(retryPossible! == true) {
					// error, user not authenticated
					self.autoLoginActivityIndicator.stopAnimating();
					self.retryAutoLoginButton.alpha = 1.0;
					if(self.alreadyFailedOnce && self.isOfflineModeIsAvailable()) {
						self.autoLoginActivityIndicator.stopAnimating();
						self.retryAutoLoginButton.alpha = 1.0;
						
						UIView.animate(withDuration: 1.0, animations: {
							self.retryAutoLoginButton.snp.remakeConstraints({(make) -> Void in
								make.centerY.equalTo(self.autoLoginActivityIndicator)
								make.width.equalTo(self.logoView.frame.width / 3)
								make.centerX.equalTo(self.view).offset(-100)
							});
							self.retryAutoLoginButton.layoutIfNeeded();
							self.view.layoutIfNeeded();
							
							self.offlineModeButton.alpha = 1.0;
							self.offlineModeButton.snp.remakeConstraints({(make) -> Void in
								make.centerY.equalTo(self.autoLoginActivityIndicator)
								make.width.equalTo(self.logoView.frame.width / 3)
								make.centerX.equalTo(self.view).offset(100)
							});
							self.offlineModeButton.layoutIfNeeded();
							self.view.layoutIfNeeded();
						});
					}
					self.alreadyFailedOnce = true;
					return;
				} else if(retryPossible! == false) {
					self.preloadLoginPageImagesAndGoToLoginPage();
					return;
				}
			}
		}
	}
	
	func isOfflineModeIsAvailable() -> Bool {
		let expiresIn = self.tokenExpiresIn?.toDate();
		if(expiresIn! >= Date() && Constants.OFFLINE_ACCESS) {
			return true;
		}
		return false;
	}
	
	@objc func replaceCurrentPageWithMainViews() {
		UIView.transition(with: (UIApplication.shared.delegate?.window!)!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
			UIApplication.shared.isStatusBarHidden = false;
			let vc = AppDelegate.initializeMainViewsLayout(window: (UIApplication.shared.delegate?.window!)!);
			UIApplication.shared.delegate?.window!?.rootViewController = vc;
		});
	}
	
	func hideAndShowViewWithAnimation(logoView: UIImageView, animationDuration: Double, delayDuration: Double, completion: @escaping () -> Void) {
		DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
			UIView.animate(withDuration: animationDuration, animations: {
				logoView.alpha = 0;
			}) { (completed) in
				DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
					UIView.animate(withDuration: animationDuration, animations: {
						logoView.alpha = 1;
					}) { (completed) in
						completion();
					}
				}
			}
		}
	}
	
}
