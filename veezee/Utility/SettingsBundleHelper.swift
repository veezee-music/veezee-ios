//
//  SettingsBundleHelper.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

class SettingsBundleHelper {
//	static func setAppVersion() {
//		let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
//		let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String;
//		
//		UserDefaults.standard.set("\(version) (\(build)) ", forKey: "version_preference");
//	}
	
	static func appSettingsBundleChanged() {
		DispatchQueue.main.async {
			if let theme = UserDefaults.standard.string(forKey: "theme_preference") {
				
				// change the app theme accordingly and refresh the view
				if(theme == "white") {
					UIApplication.shared.statusBarStyle = .default;
					Constants.PRIMARY_COLOR = Constants.WHITE_THEME.PRIMARY_COLOR;
					Constants.PRIMARY_TEXT_COLOR = Constants.WHITE_THEME.PRIMARY_TEXT_COLOR;
					Constants.PLAYER_TITLE_COLOR = Constants.WHITE_THEME.PLAYER_TITLE_COLOR;
				} else if(theme == "purpleDark") {
					// set the style of status bar so it's clearly visible
					UIApplication.shared.statusBarStyle = .lightContent;
					Constants.PRIMARY_COLOR = Constants.PURPLE_DARK_THEME.PRIMARY_COLOR;
					Constants.PRIMARY_TEXT_COLOR = Constants.PURPLE_DARK_THEME.PRIMARY_TEXT_COLOR;
					Constants.PLAYER_TITLE_COLOR = Constants.PURPLE_DARK_THEME.PLAYER_TITLE_COLOR;
				} else if(theme == "black") {
					// set the style of status bar so it's clearly visible
					UIApplication.shared.statusBarStyle = .lightContent;
					Constants.PRIMARY_COLOR = Constants.BLACK_THEME.PRIMARY_COLOR;
					Constants.PRIMARY_TEXT_COLOR = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
					Constants.PLAYER_TITLE_COLOR = Constants.BLACK_THEME.PLAYER_TITLE_COLOR;
				}
				
			}
			if let coloredPlayerPreference = UserDefaults.standard.object(forKey: "colored_player_preference") {
				if(coloredPlayerPreference as! Bool) {
					Constants.COLORED_PLAYER = true;
				} else {
					Constants.COLORED_PLAYER = false;
				}
			}
			
			if let offlineAccessPreference = UserDefaults.standard.object(forKey: "offline_access_preference") {
				if(offlineAccessPreference as! Bool) {
					Constants.OFFLINE_ACCESS = true;
				} else {
					Constants.OFFLINE_ACCESS = false;
				}
			}
		}
	}
}
