//
//  LoginRegisterContainerViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/17/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import AnimatedTextInput
import DeviceKit
import RimhTypingLetters
import GoogleSignIn
import KeychainSwift
import PMAlertController
import VSInfiniteCarousel
import Crashlytics

class LoginRegisterContainerViewController: _BaseCommonViewController, GIDSignInDelegate, GIDSignInUIDelegate {
	
	var albumArts = [String]();
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil);
	}
	
	convenience init(imagesList: [String]) {
		self.init(nibName: nil, bundle: nil);
		
		self.albumArts = imagesList;
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(nibName: nil, bundle: nil);
	}
	
	override var prefersStatusBarHidden: Bool {
		return true;
	}
	
	let nameInputTag = 395543232;
	let emailInputTag = 3918009687;
	let passwordInputTag = 39180093333;
	
	var infiniteCarousels = [UIView]();
	
	var sloganLogotypeContainerHeight: CGFloat = 100;
	let sloganLogotypeContainer = UIView();
	
	let logotype = UIImageView();
	
	var formContainer = UIVisualEffectView();
	var formContainerHeight: CGFloat = 20 * 2; // padding for top and bottom
	var formContainerWidth: CGFloat = 0;
	
	lazy var sloganView: TypingLetterUITextView = {
		let sloganView = TypingLetterUITextView();
		
		return sloganView;
	}();
	
	var headerView: UIVisualEffectView?;
	
	var registrationFormContainer = UIView();
	var registrationFormSubmitButton = LGButton();
	
	var loginFormContainer = UIView();
	var loginFormSubmitButton = LGButton();
	
	var googleLoginButton = LGButton();
	
	override func shouldCheckForUserLogin() -> Bool {
		return false;
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		UIApplication.shared.isStatusBarHidden = true;
		
		self.audioPlayer.stop();
		
		for _ in 1...5 {
			let view = UIView();
			view.layer.zPosition = 0;
			
			self.infiniteCarousels.append(view);
		}
		
		self.view.backgroundColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		self.view.layer.zPosition = 1;
		
		let pageOverlay = UIView();
		self.view.addSubview(pageOverlay);
		pageOverlay.snp.makeConstraints ({(make) in
			make.width.height.equalTo(self.view)
			make.top.bottom.equalTo(0)
		});
		pageOverlay.layer.zPosition = 2;
		pageOverlay.backgroundColor = .black;
		
		let logoView = UIImageView();
		logoView.image = UIImage(named: "logo-basic-white");
		logoView.contentMode = .scaleAspectFit;
		self.view.addSubview(logoView);
		logoView.snp.makeConstraints({(make) -> Void in
			make.centerX.centerY.equalTo(self.view)
			make.width.lessThanOrEqualTo(self.view.frame.width / (self.wC() ? 2 : 3))
			make.height.lessThanOrEqualTo((self.view.frame.width / (self.wC() ? 2 : 3)) / 1.5)
		});
		logoView.layer.zPosition = 8;
		
		self.hideAndShowViewWithAnimation(logoView: logoView, animationDuration: 0.5, delayDuration: 0.3, completion: {
			UIView.animate(withDuration: 1, animations: {
				// clear the background so the content behind is visible
				pageOverlay.backgroundColor = .clear;
			}, completion: { (completed) in
				
				let darkBlurEffect = UIBlurEffect(style: .dark);
				self.headerView = UIVisualEffectView(effect: darkBlurEffect);
				self.view.addSubview(self.headerView!);
				self.headerView!.frame = self.headerView!.frame.integral;
				
				let extraLightVibrancyView = self.vibrancyEffectView(forBlurEffectView: self.headerView!);
				self.headerView!.contentView.addSubview(extraLightVibrancyView);
				
				self.headerView!.snp.makeConstraints { (make) in
					make.top.equalTo(-self.view.frame.height / CGFloat(self.infiniteCarousels.count))
					make.width.equalTo(self.view.frame.width);
					make.height.equalTo(self.view.frame.height / CGFloat(self.infiniteCarousels.count))
				}
				self.headerView!.layer.zPosition = 7;
				
				self.sloganLogotypeContainer.backgroundColor = Constants.ACCENT_COLOR;
				self.view.addSubview(self.sloganLogotypeContainer);
				self.sloganLogotypeContainer.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(0).inset(-self.sloganLogotypeContainerHeight)
					make.width.equalToSuperview()
					make.height.greaterThanOrEqualTo(self.sloganLogotypeContainerHeight)
				});
				self.sloganLogotypeContainer.layer.zPosition = 7;
				
				self.layoutChooseFormContainerWithoutShowing();
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
					UIView.animate(withDuration: 1.0, animations: {
						
						// pull the header down
						self.headerView!.snp.remakeConstraints { (make) in
							make.top.equalTo(0)
							make.width.equalTo(self.view.frame.width);
							make.height.equalTo(self.view.frame.height / CGFloat(self.infiniteCarousels.count))
						}
						self.headerView!.layoutIfNeeded();
						self.view.layoutIfNeeded();
						
						if(self.albumArts.count <= 0) {
							self.animateSloganLogoTypeSetup();
						}
						
						// move the logo to the header
						logoView.snp.remakeConstraints({(make) -> Void in
							make.centerX.centerY.equalTo(self.headerView!)
							make.width.lessThanOrEqualTo(self.view.frame.width / 4)
							make.height.lessThanOrEqualTo((self.view.frame.width / 4) / 1.5)
						});
						logoView.layoutIfNeeded();
						self.view.layoutIfNeeded();
						
						self.formContainer.snp.remakeConstraints({(make) -> Void in
							make.width.equalTo(self.formContainerWidth)
							make.height.equalTo(self.formContainerHeight)
							make.centerX.centerY.equalTo(self.view)
						});
						self.formContainer.layoutIfNeeded();
						self.view.layoutIfNeeded();
						
					});
				});
				
			})
		});
		
		self.layoutRegistrationForm();
		self.layoutLoginForm();
		
		let gradient = CAGradientLayer()
		gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
		gradient.locations = [0, 0.2, 0.8, 1]
		gradient.frame = view.bounds
		gradient.colors = [UIColor.clear.cgColor, Constants.BLACK_THEME.PRIMARY_COLOR.cgColor, Constants.BLACK_THEME.PRIMARY_COLOR.cgColor, UIColor.clear.cgColor]
		self.view.layer.mask = gradient
		
		let gradient2 = CAGradientLayer();
		gradient2.frame = self.view.bounds;
		gradient2.colors = [Constants.BLACK_THEME.PRIMARY_COLOR.cgColor, UIColor.white.cgColor];
		self.view.layer.addSublayer(gradient2);
		
		if(self.albumArts.count > 0) {
			self.addInfiniteCarousels();
		}
	}
	
	func animateSloganLogoTypeSetup() {
		sloganLogotypeContainer.snp.remakeConstraints({(make) -> Void in
			make.top.equalTo(self.headerView!.snp.bottom)
			make.width.equalToSuperview()
			make.height.greaterThanOrEqualTo(sloganLogotypeContainerHeight)
		});
		sloganLogotypeContainer.layoutIfNeeded();
		
		sloganView.backgroundColor = .clear;
		sloganView.textColor = .white;
		sloganLogotypeContainer.addSubview(sloganView);
		sloganView.font = UIFont.systemFont(ofSize: self.device.isPad ? 35 : 20, weight: UIFont.Weight.heavy);
		
		sloganView.snp.makeConstraints({(make) -> Void in
			make.centerX.equalTo(self.view)
			make.width.height.equalTo(sloganLogotypeContainer)
			make.top.equalTo((sloganLogotypeContainerHeight - 60) / 2)
		});
		sloganView.textAlignment = .center;
		sloganView.layoutIfNeeded();
		
		logotype.contentMode = .scaleAspectFit;
		logotype.image = UIImage(named: "logotype-white");
		logotype.alpha = 0;
		self.sloganLogotypeContainer.addSubview(logotype);
		logotype.snp.makeConstraints({(make) -> Void in
			make.width.equalTo(200)
			make.height.equalTo(31)
			make.top.equalTo((self.sloganLogotypeContainerHeight - 31) / 2)
			make.centerX.equalTo(self.view)
		});
		
		self.changeSlogan();
	}
	
	func layoutChooseFormContainerWithoutShowing() {
		let darkBlurEffect = UIBlurEffect(style: .dark);
		self.formContainer = UIVisualEffectView(effect: darkBlurEffect);
		self.formContainerWidth = self.device.isPad ? ((self.view.frame.width / 2) + (20 * 2)) : self.view.frame.width - 50;
		
		formContainer.frame = formContainer.frame.integral;
		
		let extraLightVibrancyView = formContainer;
		
		// the reason I commented the vibrancy effect is that it really makes the text unreadble in my case
//		let extraLightVibrancyView = self.vibrancyEffectView(forBlurEffectView: formContainerWithDarkBlurView)
//		formContainerWithDarkBlurView.contentView.addSubview(extraLightVibrancyView)
		
		formContainer.layer.zPosition = 8
		formContainer.layer.cornerRadius = 4;
		formContainer.clipsToBounds = true;
		
		extraLightVibrancyView.layer.cornerRadius = 4;
		extraLightVibrancyView.clipsToBounds = true
		
		self.view.addSubview(formContainer);
		formContainer.snp.makeConstraints({(make) -> Void in
			make.width.equalTo(formContainerWidth)
			make.centerX.equalTo(self.view)
			make.top.equalTo(self.view.frame.height)
		});
		formContainer.layoutIfNeeded();
		
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
		loginButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.loginButtonClicked), for: .touchUpInside);
		
		extraLightVibrancyView.contentView.addSubview(loginButton);
		loginButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(20)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		loginButton.layoutIfNeeded();
		formContainerHeight += loginButton.frame.height;
		
		googleLoginButton.mainStackView.arrangedSubviews.first?.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: UILayoutConstraintAxis.horizontal);
		googleLoginButton.mainStackView.distribution = .fill;
		googleLoginButton.mainStackView.alignment = .center;
		googleLoginButton.spacingTitleIcon = 0;
		googleLoginButton.titleString = "Log in with Google";
		googleLoginButton.leftImageSrc = UIImage(named: "google-g");
		googleLoginButton.titleFontSize = 18;
		googleLoginButton.titleColor = .black;
		googleLoginButton.cornersRadius = 4;
		googleLoginButton.bgColor = .white;
		googleLoginButton.shadowRadius = 4;
		googleLoginButton.shadowOpacity = 2;
		googleLoginButton.shadowOffset = CGSize(width: 0, height: 1);
		googleLoginButton.shadowColor = .white;
		googleLoginButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.googleLoginButtonClicked), for: .touchUpInside);
		googleLoginButton.loadingColor = .black;
		googleLoginButton.loadingString = "Please wait...";
		googleLoginButton.loadingSpinnerColor = .black;
		
		extraLightVibrancyView.contentView.addSubview(googleLoginButton);
		googleLoginButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(loginButton.snp.bottom).offset(20)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		googleLoginButton.layoutIfNeeded();
		formContainerHeight += (googleLoginButton.frame.height + 20);
		
		let orHintView = UILabel();
		orHintView.text = "Or";
		orHintView.textColor = .white;
		orHintView.numberOfLines = 0;
		orHintView.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold);
		orHintView.textAlignment = .center;
		extraLightVibrancyView.contentView.addSubview(orHintView);
		orHintView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(googleLoginButton.snp.bottom).offset(20)
			make.height.greaterThanOrEqualTo(20)
			make.centerX.equalTo(self.view)
		});
		orHintView.layoutIfNeeded();
		formContainerHeight += (orHintView.frame.height + 20);
		
		let leftLine = UIView();
		leftLine.backgroundColor = .white;
		formContainer.contentView.addSubview(leftLine)
		leftLine.snp.makeConstraints({(make) -> Void in
			make.left.equalTo(0)
			make.height.equalTo(2)
			make.centerY.equalTo(orHintView)
			make.width.equalTo((formContainerWidth / 2) - orHintView.frame.width)
		});
		
		let rightLine = UIView();
		rightLine.backgroundColor = .white;
		formContainer.contentView.addSubview(rightLine)
		rightLine.snp.makeConstraints({(make) -> Void in
			make.right.equalTo(0)
			make.height.equalTo(2)
			make.centerY.equalTo(orHintView)
			make.width.equalTo((formContainerWidth / 2) - orHintView.frame.width)
		});
		
		let registrationButton = LGButton();
		registrationButton.titleString = "Create a new account";
		registrationButton.titleFontSize = 18;
		registrationButton.titleColor = .white;
		registrationButton.cornersRadius = 4;
		registrationButton.bgColor = Constants.ACCENT_COLOR;
		registrationButton.shadowRadius = 4;
		registrationButton.shadowOpacity = 2;
		registrationButton.shadowOffset = CGSize(width: 0, height: 1);
		registrationButton.shadowColor = Constants.ACCENT_COLOR;
		registrationButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.registrationButtonClicked), for: .touchUpInside);
		
		extraLightVibrancyView.contentView.addSubview(registrationButton);
		registrationButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(orHintView.snp.bottom).offset(20)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		registrationButton.layoutIfNeeded();
		formContainerHeight += (registrationButton.frame.height + 20);
	}
	
	@objc
	func googleLoginButtonClicked() {
		self.googleLoginButton.isLoading = true;
		GIDSignIn.sharedInstance().signOut();
		GIDSignIn.sharedInstance().delegate = self;
		GIDSignIn.sharedInstance().uiDelegate = self;
		GIDSignIn.sharedInstance().signIn();
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		self.googleLoginButton.isLoading = true;
		self.present(viewController, animated: true, completion: nil);
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		self.dismiss(animated: true, completion: nil);
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		
		if(error != nil) {
			// failure
			
			if(error._code == GIDSignInErrorCode.canceled.rawValue) {
				// user canceled the propmt
				self.googleLoginButton.isLoading = false;
				return;
			}
			
			let errorAC = PMAlertController(title: "Error", description: "An error occured while trying to log in using Google. Make sure your Google account is accessible and iOS is up to date.", image: nil, style: .alert);
			errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
			errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
			errorAC.show();
			self.googleLoginButton.isLoading = false;
			
			return;
		}
		
		if(user.serverAuthCode == nil) {
			let errorAC = PMAlertController(title: "Error", description: "Google login is not available right now. Please log-in using your email and password.", image: nil, style: .alert);
			errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
			errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
			errorAC.show();
			self.googleLoginButton.isLoading = false;
			
			return;
		}
		
		self.googleLoginButton.isLoading = true;
		
		API.Account.processGoogleLogin(serverAuthCode: user.serverAuthCode) { (userLoginResult, errorMessage) in
			self.googleLoginButton.isLoading = false;
			if(userLoginResult != nil && userLoginResult?.token != nil && errorMessage == nil) {
				// success
				self.keychain.set(userLoginResult!.token!, forKey: "token", withAccess: .accessibleAfterFirstUnlock);
				self.keychain.set(userLoginResult!.expiresIn!.toDateTimeString(), forKey: "expiresIn", withAccess: .accessibleAfterFirstUnlock);
				self.keychain.set(userLoginResult!.access!.expiresIn!.toDateTimeString(), forKey: "accessExpiresIn", withAccess: .accessibleAfterFirstUnlock);
				
				self.afterLogin();
			} else {
				let errorAC = PMAlertController(title: "Error", description: errorMessage!, image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
			}
		}
	}
	
	func afterLogin() {
		UIView.transition(with: (UIApplication.shared.delegate?.window!)!, duration: 0.3, options: .transitionFlipFromBottom, animations: {
			// update the expiration session date
			AppDelegate.autoLoginSessionExpireDate = getDateTimeForHoursInTheFuture(hours: 6);
			UIApplication.shared.isStatusBarHidden = false;
			// initialize the main pages (tabs) included in the tab bar controller and pass the tab bar controller to the window
			let vc = AppDelegate.initializeMainViewsLayout(window: (UIApplication.shared.delegate?.window!)!);
			UIApplication.shared.delegate?.window!?.rootViewController = vc;
		});
	}

	func addInfiniteCarousels() {
		for (index, view) in self.infiniteCarousels.enumerated() {
			self.view.addSubview(view);
			view.snp.makeConstraints({(make) -> Void in
				make.width.equalTo(self.view.bounds.width);
				make.height.equalTo(self.view.frame.height / CGFloat(self.infiniteCarousels.count));
			});
			if(index <= 0) {
				view.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(0)
				});
			} else {
				view.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(self.infiniteCarousels[index - 1].snp.bottom)
				});
			}
			view.layoutIfNeeded();
		}
		
		let albumArtsCount = self.albumArts.count;
		// we cut the images list in two as it prevents continuous carousels to show the same set of images
		let firstHalfOfAlbumArts = Array(self.albumArts[0...albumArtsCount / 2]);
		let secondHalfOfAlbumArts = Array(self.albumArts[(albumArtsCount / 2) + 1...albumArtsCount - 1]);
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.initializeInfiniteCarousel(forCarouselRow: 0, withImages: firstHalfOfAlbumArts);
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.initializeInfiniteCarousel(forCarouselRow: 1, withImages: secondHalfOfAlbumArts);
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
			self.initializeInfiniteCarousel(forCarouselRow: 2, withImages: firstHalfOfAlbumArts);
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
			self.initializeInfiniteCarousel(forCarouselRow: 3, withImages: secondHalfOfAlbumArts);
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			self.initializeInfiniteCarousel(forCarouselRow: 4, withImages: firstHalfOfAlbumArts);
		}
	}
	
	func vibrancyEffectView(forBlurEffectView blurEffectView: UIVisualEffectView) -> UIVisualEffectView {
		let vibrancy = UIVibrancyEffect(blurEffect: blurEffectView.effect as! UIBlurEffect);
		let vibrancyView = UIVisualEffectView(effect: vibrancy);
		vibrancyView.frame = blurEffectView.bounds;
		vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
		return vibrancyView;
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
	
	func initializeInfiniteCarousel(forCarouselRow: Int, withImages images: [String]) {
		var items = [UIView]();
		for n in images {
			let view = UIImageView();
			view.image = UIImage(named: "artwork");
			view.kf.setImage(with: URL(string: n), placeholder: UIImage(named: "artwork"));
			view.contentMode = .scaleAspectFill;
			view.clipsToBounds = true;
			view.layer.cornerRadius = 4;
			
			items.append(view);
		}
		
		let infiniteCarousel = VSInfiniteCarousel(containerView: self.infiniteCarousels[forCarouselRow], itemFrame: CGRect(x: 0, y: 0, width: (self.view.frame.height / CGFloat(self.infiniteCarousels.count)) - 20, height: (self.view.frame.height / CGFloat(self.infiniteCarousels.count)) - 20), inset: 20, updateInterval: 1.5);
		infiniteCarousel.initializeViewsList(viewsList: items);
	}
	
	var noOfChangedSlogans = 0;
	let slogans = ["Unlimited Music", "Online and Offline", "Synced Between Devices"];
	@objc
	func changeSlogan() {
		if(self.noOfChangedSlogans == self.slogans.count) {
			DispatchQueue.main.async {
				UIView.animate(withDuration: 0.5, animations: {
					self.sloganView.alpha = 0;
					self.logotype.alpha = 1;
				});
			}
			return;
		}
		
		sloganView.typeText(self.slogans[self.noOfChangedSlogans], delimiter: " ", typingSpeedPerChar: 0.1, didResetContent: true) {
			// complete action after finished typing
			self.noOfChangedSlogans += 1;
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
				self.changeSlogan();
			}
		}
	}
	
}

// MARK: - Login form
extension LoginRegisterContainerViewController {
	@objc
	func loginButtonClicked() {
		UIView.animate(withDuration: 0.5) {
			self.loginFormContainer.alpha = 1.0;
			self.view.bringSubview(toFront: self.loginFormContainer);
		}
	}
	
	@objc
	func loginFormCancelClicked() {
		UIView.animate(withDuration: 0.5) {
			self.loginFormContainer.alpha = 0.0;
			self.view.sendSubview(toBack: self.loginFormContainer);
		}
	}
	
	func doLogin(email: String, password: String) {
		self.loginFormSubmitButton.isLoading = true;
		
		API.Account.logIn(email: email, password: password) { (userLoginResult, errorMessage) in
			self.loginFormSubmitButton.isLoading = false;
			if(userLoginResult != nil && userLoginResult?.token != nil && errorMessage == nil) {
				// success
				self.keychain.set(userLoginResult!.token!, forKey: "token", withAccess: .accessibleAfterFirstUnlock);
				self.keychain.set(userLoginResult!.expiresIn!.toDateTimeString(), forKey: "expiresIn", withAccess: .accessibleAfterFirstUnlock);
				self.keychain.set(userLoginResult!.access!.expiresIn!.toDateTimeString(), forKey: "accessExpiresIn", withAccess: .accessibleAfterFirstUnlock);
				
				self.afterLogin();
			} else {
				let errorAC = PMAlertController(title: "Error", description: errorMessage!, image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
			}
		}
	}
	
	@objc
	func loginFormSubmitClicked() {
		let emailInput = self.loginFormContainer.viewWithTag(emailInputTag) as! AnimatedTextInput;
		let passwordInput = self.loginFormContainer.viewWithTag(passwordInputTag) as! AnimatedTextInput;
		
		self.doLogin(email: emailInput.text!, password: passwordInput.text!);
	}
	
	// MARK: Lays out the layout of the login form but does not show it
	func layoutLoginForm() {
		let containerViewWidth = self.device.isPad ? ((self.view.frame.width / 1.5) + (20 * 2)) : self.view.frame.width - 50;
		
		loginFormContainer.layer.zPosition = 10;
		loginFormContainer.cornerRadius = 4;
		loginFormContainer.clipsToBounds = true;
		loginFormContainer.backgroundColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		loginFormContainer.alpha = 0;
		self.view.addSubview(loginFormContainer);
		loginFormContainer.snp.makeConstraints({(make) -> Void in
			make.width.equalTo(containerViewWidth);
			make.centerX.centerY.equalTo(self.view)
		});
		loginFormContainer.layoutIfNeeded();
		
		var childViewsFullHeight: CGFloat = 0;
		
		let titleView = UILabel();
		titleView.text = "Login to your account";
		titleView.textColor = .white;
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		titleView.font = boldFont.withSize(25);
		
		loginFormContainer.addSubview(titleView);
		titleView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(30)
			make.centerX.equalTo(self.view)
		});
		titleView.layoutIfNeeded();
		childViewsFullHeight += titleView.bounds.height + 30;
		
		let emailInput = AnimatedTextInput();
		emailInput.tag = emailInputTag;
		emailInput.style = CustomAnimatedTextInputStyle();
		emailInput.type = .email;
		emailInput.placeHolderText = "Your email";
		
		loginFormContainer.addSubview(emailInput);
		emailInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(titleView.snp.bottom)
			make.left.right.equalTo(0)
		});
		emailInput.layoutIfNeeded();
		childViewsFullHeight += emailInput.bounds.height;
		
		let passwordInput = AnimatedTextInput();
		passwordInput.tag = passwordInputTag;
		passwordInput.style = CustomAnimatedTextInputStyle();
		passwordInput.type = .password(toggleable: true);
		passwordInput.placeHolderText = "Your password";
		
		loginFormContainer.addSubview(passwordInput);
		passwordInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(emailInput.snp.bottom)
			make.left.right.equalTo(0)
		});
		passwordInput.layoutIfNeeded();
		childViewsFullHeight += passwordInput.bounds.height;
		
		loginFormSubmitButton.titleString = "Log in";
		loginFormSubmitButton.titleFontSize = 18;
		loginFormSubmitButton.titleColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		loginFormSubmitButton.cornersRadius = 4;
		loginFormSubmitButton.bgColor = Constants.ACCENT_COLOR;
		loginFormSubmitButton.shadowRadius = 4;
		loginFormSubmitButton.shadowOpacity = 2;
		loginFormSubmitButton.shadowOffset = CGSize(width: 0, height: 1);
		loginFormSubmitButton.shadowColor = Constants.ACCENT_COLOR;
		loginFormSubmitButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.loginFormSubmitClicked), for: .touchUpInside);
		loginFormSubmitButton.loadingColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		loginFormSubmitButton.loadingString = "Please wait...";
		loginFormSubmitButton.loadingSpinnerColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		
		loginFormContainer.addSubview(loginFormSubmitButton);
		loginFormSubmitButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(passwordInput.snp.bottom).offset(30)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		loginFormSubmitButton.layoutIfNeeded();
		childViewsFullHeight += (loginFormSubmitButton.bounds.height + 30);
		
		let cancelButton = UIButton();
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14);
		cancelButton.setTitle("Cancel", for: .normal);
		cancelButton.setTitleColor(UIColor.lightGray, for: .normal);
		cancelButton.setTitleColor(UIColor.gray, for: .highlighted);
		loginFormContainer.addSubview(cancelButton);
		cancelButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(loginFormSubmitButton.snp.bottom).offset(30 / 2)
			make.left.right.equalTo(0)
		});
		cancelButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.loginFormCancelClicked), for: .touchUpInside);
		cancelButton.layoutIfNeeded();
		childViewsFullHeight += (cancelButton.bounds.height + 30);
		
		loginFormContainer.snp.makeConstraints({(make) -> Void in
			make.centerX.centerY.equalTo(self.view)
			make.width.equalTo(containerViewWidth)
			make.height.equalTo(childViewsFullHeight)
		});
	}
}

// MARK: - Registration form
extension LoginRegisterContainerViewController {
	@objc
	func registrationButtonClicked() {
		UIView.animate(withDuration: 0.5) {
			self.registrationFormContainer.alpha = 1.0;
			self.view.bringSubview(toFront: self.registrationFormContainer);
		}
	}
	
	@objc
	func registrationFormCancelClicked() {
		UIView.animate(withDuration: 0.5) {
			self.registrationFormContainer.alpha = 0.0;
			self.view.sendSubview(toBack: self.registrationFormContainer);
		}
	}
	
	func doRegister(name: String, email: String, password: String) {
		self.registrationFormSubmitButton.isLoading = true;
		
		API.Account.register(name: name, email: email, password: password) { (user, errorMessage) in
			self.registrationFormSubmitButton.isLoading = false;
			if(user != nil && user?.email != nil && errorMessage == nil) {
				// success
				Answers.logSignUp(withMethod: "email-password", success: true, customAttributes: nil);
				self.doLogin(email: email, password: password);
			} else {
				Answers.logSignUp(withMethod: "email-password", success: false, customAttributes: ["error": errorMessage ?? "Unkown"]);
				let errorAC = PMAlertController(title: "Error", description: errorMessage ?? "Unkown", image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
			}
		}
	}
	
	@objc
	func registrationFormSubmitClicked() {
		let nameInput = self.registrationFormContainer.viewWithTag(nameInputTag) as! AnimatedTextInput;
		let emailInput = self.registrationFormContainer.viewWithTag(emailInputTag) as! AnimatedTextInput;
		let passwordInput = self.registrationFormContainer.viewWithTag(passwordInputTag) as! AnimatedTextInput;
		
		self.doRegister(name: nameInput.text!, email: emailInput.text!, password: passwordInput.text!);
	}
	
	// MARK: Lays out the layout of the registration form but does not show it
	func layoutRegistrationForm() {
		let containerViewWidth = self.device.isPad ? ((self.view.frame.width / 1.5) + (20 * 2)) : self.view.frame.width - 50;
		
		registrationFormContainer.layer.zPosition = 10;
		registrationFormContainer.cornerRadius = 4;
		registrationFormContainer.clipsToBounds = true;
		registrationFormContainer.backgroundColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		registrationFormContainer.alpha = 0;
		self.view.addSubview(registrationFormContainer);
		registrationFormContainer.snp.makeConstraints({(make) -> Void in
			make.width.equalTo(containerViewWidth);
			make.centerX.centerY.equalTo(self.view)
		});
		registrationFormContainer.layoutIfNeeded();
		
		var childViewsFullHeight: CGFloat = 0;
		
		let titleView = UILabel();
		titleView.text = "Create an account";
		titleView.textColor = .white;
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		titleView.font = boldFont.withSize(25);
		
		registrationFormContainer.addSubview(titleView);
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
		nameInput.placeHolderText = "Your display name";
		
		registrationFormContainer.addSubview(nameInput);
		nameInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(titleView.snp.bottom)//.offset(30)
			make.left.right.equalTo(0)
		});
		nameInput.layoutIfNeeded();
		childViewsFullHeight += (nameInput.bounds.height + 0);
		
		let emailInput = AnimatedTextInput();
		emailInput.tag = emailInputTag;
		emailInput.style = CustomAnimatedTextInputStyle();
		emailInput.type = .email;
		emailInput.placeHolderText = "Your email";
		
		registrationFormContainer.addSubview(emailInput);
		emailInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(nameInput.snp.bottom)
			make.left.right.equalTo(0)
		});
		emailInput.layoutIfNeeded();
		childViewsFullHeight += emailInput.bounds.height;
		
		let passwordInput = AnimatedTextInput();
		passwordInput.tag = passwordInputTag;
		passwordInput.style = CustomAnimatedTextInputStyle();
		passwordInput.type = .password(toggleable: true);
		passwordInput.placeHolderText = "Your password";
		
		registrationFormContainer.addSubview(passwordInput);
		passwordInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(emailInput.snp.bottom)
			make.left.right.equalTo(0)
		});
		passwordInput.layoutIfNeeded();
		childViewsFullHeight += passwordInput.bounds.height;
		
		registrationFormSubmitButton.titleString = "Register";
		registrationFormSubmitButton.titleFontSize = 18;
		registrationFormSubmitButton.titleColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		registrationFormSubmitButton.cornersRadius = 4;
		registrationFormSubmitButton.bgColor = Constants.ACCENT_COLOR;
		registrationFormSubmitButton.shadowRadius = 4;
		registrationFormSubmitButton.shadowOpacity = 2;
		registrationFormSubmitButton.shadowOffset = CGSize(width: 0, height: 1);
		registrationFormSubmitButton.shadowColor = Constants.ACCENT_COLOR;
		registrationFormSubmitButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.registrationFormSubmitClicked), for: .touchUpInside);
		registrationFormSubmitButton.loadingColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		registrationFormSubmitButton.loadingString = "Please wait...";
		registrationFormSubmitButton.loadingSpinnerColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		
		registrationFormContainer.addSubview(registrationFormSubmitButton);
		registrationFormSubmitButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(passwordInput.snp.bottom).offset(30)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		registrationFormSubmitButton.layoutIfNeeded();
		childViewsFullHeight += (registrationFormSubmitButton.bounds.height + 30);
		
		let cancelButton = UIButton();
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14);
		cancelButton.setTitle("Cancel", for: .normal);
		cancelButton.setTitleColor(UIColor.lightGray, for: .normal);
		cancelButton.setTitleColor(UIColor.gray, for: .highlighted);
		registrationFormContainer.addSubview(cancelButton);
		cancelButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(registrationFormSubmitButton.snp.bottom).offset(30 / 2)
			make.left.right.equalTo(0)
		});
		cancelButton.addTarget(self, action: #selector(LoginRegisterContainerViewController.registrationFormCancelClicked), for: .touchUpInside);
		cancelButton.layoutIfNeeded();
		childViewsFullHeight += (cancelButton.bounds.height + 30);
		
		registrationFormContainer.snp.makeConstraints({(make) -> Void in
			make.centerX.centerY.equalTo(self.view)
			make.width.equalTo(containerViewWidth)
			make.height.equalTo(childViewsFullHeight)
		});
	}
}


struct CustomAnimatedTextInputStyle: AnimatedTextInputStyle {
	let placeholderInactiveColor = UIColor.gray
	let activeColor = Constants.ACCENT_COLOR;
	let inactiveColor = UIColor.gray.withAlphaComponent(0.3)
	let lineInactiveColor = UIColor.gray.withAlphaComponent(0.3)
	let lineActiveColor = UIColor.gray.withAlphaComponent(0.4)
	let lineHeight: CGFloat = 1
	let errorColor = UIColor.red
	let textInputFont = UIFont.systemFont(ofSize: 17)
	let textInputFontColor = UIColor.white
	let placeholderMinFontSize: CGFloat = 14
	let counterLabelFont: UIFont? = UIFont.systemFont(ofSize: 9)
	let leftMargin: CGFloat = 20;
	let topMargin: CGFloat = 30
	let rightMargin: CGFloat = 20;
	let bottomMargin: CGFloat = 10
	let yHintPositionOffset: CGFloat = 7
	let yPlaceholderPositionOffset: CGFloat = 2.5
	public let textAttributes: [String: Any]? = nil
}


