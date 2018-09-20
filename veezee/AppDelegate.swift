//
//  AppDelegate.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/26/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import SwiftIcons
import MediaPlayer
import Alamofire
import CodableAlamofire
import GoogleSignIn
import KeychainSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	static var autoLoginSessionExpireDate: Date = Date();
	
	var window: UIWindow?;

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let userDefaults = UserDefaults.standard;
		// a hack to make sure keychain is cleared on app reinstall
		if userDefaults.bool(forKey: "hasRunBefore") == false {
			// Remove Keychain items here
			let keychain = KeychainSwift();
			keychain.clear();
			// Update the flag indicator
			userDefaults.set(true, forKey: "hasRunBefore");
			userDefaults.synchronize(); // Forces the app to update UserDefaults
		}
		SettingsBundleHelper.appSettingsBundleChanged();
		
		Constants.createCacheFoldersIfDoesNotExist();
		
		// set SplashScreenViewController as the apps initial VC
		self.window = UIWindow(frame: UIScreen.main.bounds);

		self.window?.rootViewController = SplashScreenViewController();
		self.window?.backgroundColor = UIColor.black;
		self.window?.makeKeyAndVisible();
		
		Fabric.with([Crashlytics.self, Answers.self]);
		
		// Enables lockscreen controls for audio player
		UIApplication.shared.beginReceivingRemoteControlEvents();
		
		GIDSignIn.sharedInstance().clientID = Constants.GOOGLE_iOS_CLIENT_ID;
		GIDSignIn.sharedInstance().serverClientID = Constants.GOOGLE_SERVER_CLIENT_ID;
		GIDSignIn.sharedInstance().shouldFetchBasicProfile = true;
		
		return true;
	}
	
	override func remoteControlReceived(with event: UIEvent?) {
		if let event = event {
			AudioPlayer.shared.remoteControlReceived(with: event);
		}
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		return GIDSignIn.sharedInstance().handle(url,
												 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
												 annotation: options[UIApplicationOpenURLOptionsKey.annotation]);
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func fixPossibleNetworkCredentialErrors() {
		let protectionSpace = URLProtectionSpace.init(host: "host.com",
													  port: 80,
													  protocol: "http",
													  realm: nil,
													  authenticationMethod: nil);
		
		let credential: URLCredential? = URLCredentialStorage.shared.defaultCredential(for: protectionSpace);
		URLCredentialStorage.shared.setDefaultCredential(credential!, for: protectionSpace);
		
		let userCredential = URLCredential(user: "username",
										   password: "password",
										   persistence: .permanent);
		
		URLCredentialStorage.shared.setDefaultCredential(userCredential, for: protectionSpace);
	}
}

extension AppDelegate {
	static func initializeMainViewsLayout(window: UIWindow) -> UITabBarController {
		let reachability = Reachability();
		
		var tabBarController: UITabBarController?;
		let navigationAppearance = UINavigationBar.appearance();
		// change color of navigation bar background
		navigationAppearance.barTintColor = Constants.PRIMARY_COLOR;
		// when navigation bar is translucent, it changes the alpha for the background color, so disable it to avoid the side effect
		navigationAppearance.isTranslucent = false;
		// change color of navigation bar items (buttons)
		navigationAppearance.tintColor = Constants.WHITE_THEME.PRIMARY_COLOR;
		if(Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR) {
			navigationAppearance.tintColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		}
		
		// change the cursor indicator on text input files
		UITextField.appearance().tintColor = Constants.PRIMARY_TEXT_COLOR;
		
		navigationAppearance.titleTextAttributes = [
			.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy),
			.foregroundColor: Constants.PRIMARY_TEXT_COLOR
		];
		navigationAppearance.largeTitleTextAttributes = [
			.foregroundColor: Constants.PRIMARY_TEXT_COLOR
		];
		// for example cancel button for search bar
		let navbarButtonAttributes = [NSAttributedStringKey.foregroundColor: Constants.PRIMARY_TEXT_COLOR];
		UIBarButtonItem.appearance().setTitleTextAttributes(navbarButtonAttributes , for: UIControlState.normal);
		
		tabBarController = UITabBarController();
		let unselectedTabBarTintColor : UIColor = .gray;
		tabBarController?.tabBar.unselectedItemTintColor = unselectedTabBarTintColor;
		tabBarController?.tabBar.tintColor = Constants.ACCENT_COLOR;
		// change background color of tabbar
		tabBarController?.tabBar.barTintColor = Constants.PRIMARY_COLOR;
		tabBarController?.tabBar.isTranslucent = false;
		// a hack to hide the hair line above the tab bar
		tabBarController?.tabBar.shadowImage = UIImage();
		tabBarController?.tabBar.backgroundImage = UIImage();
		
		let browseViewController = (reachability.isReachable() && !Constants.FORCE_OFFLINE_USAGE) ? BrowseViewController() : OfflineBrowseViewController();
		browseViewController.tabBarItem = UITabBarItem(title: "Browse", image: nil, tag: 0);
		browseViewController.tabBarItem.setIcon(icon: .ionicons(IoniconsType.iosMusicalNotes), size: CGSize(width: 38, height: 38), textColor: unselectedTabBarTintColor, backgroundColor: .clear, selectedTextColor: Constants.ACCENT_COLOR, selectedBackgroundColor: .clear);
		let browseNavigationController = UINavigationController(rootViewController: browseViewController);
		// hide the hair line under navigation bar
		browseNavigationController.navigationBar.setValue(true, forKey: "hidesShadow");
		
		let searchViewController = SearchViewController();
		searchViewController.tabBarItem = UITabBarItem(title: "Search", image: nil, tag: 1);
		searchViewController.tabBarItem.setIcon(icon: .ionicons(IoniconsType.iosSearchStrong), size: CGSize(width: 38, height: 38), textColor: unselectedTabBarTintColor, backgroundColor: .clear, selectedTextColor: Constants.ACCENT_COLOR, selectedBackgroundColor: .clear);
		let searchNavigationController = UINavigationController(rootViewController: searchViewController);
		// hide the hair line under navigation bar
		searchNavigationController.navigationBar.setValue(true, forKey: "hidesShadow");
		
		let accountViewController = AccountViewController();
		accountViewController.tabBarItem = UITabBarItem(title: "Account", image: nil, tag: 2);
		accountViewController.tabBarItem.setIcon(icon: .ionicons(IoniconsType.iosPerson), size: CGSize(width: 38, height: 38), textColor:
			unselectedTabBarTintColor, backgroundColor: .clear, selectedTextColor: Constants.ACCENT_COLOR, selectedBackgroundColor: .clear);
		let accountNavigationController = UINavigationController(rootViewController: accountViewController);
		// hide the hair line under navigation bar
		accountNavigationController.navigationBar.setValue(true, forKey: "hidesShadow");
		
		var controllers = [browseNavigationController as Any, searchNavigationController as Any] as [Any];
		
		if(!Constants.GUEST_MODE) {
			controllers.append(accountNavigationController as Any);
		}
		
		tabBarController?.viewControllers = controllers as? [UIViewController];
		
		return tabBarController!;
	}
}
