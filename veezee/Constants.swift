//
//  Constants.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/26/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

struct Constants {
	
	/// Enabling this flag disables all user specific functionality including registration/login and account page
	static var GUEST_MODE = true;
	/// Enabling this flag forces the application to always launch in offline mode, it may dynamically change during app life cycle
	static var FORCE_OFFLINE_USAGE = false;
	/// Max time out for API calls
	static var API_TIME_OUT: Double = 20;
	
	static var API_BASE_URL = "https://veezee.cloud/api/v1";
	
	static var GOOGLE_iOS_CLIENT_ID: String {
		get {
			if let appConfig = Bundle.main.object(forInfoDictionaryKey: "VZAppConfig") as? [String: String] {
				return appConfig["GoogleiOSClientId"] ?? "";
			}
			
			return "";
		}
	}
	static var GOOGLE_SERVER_CLIENT_ID: String {
		get {
			if let appConfig = Bundle.main.object(forInfoDictionaryKey: "VZAppConfig") as? [String: String] {
				return appConfig["GoogleServerClientId"] ?? "";
			}
			
			return "";
		}
	}
	
	static var PRIMARY_COLOR = WHITE_THEME.PRIMARY_COLOR;
	static var ACCENT_COLOR = WHITE_THEME.ACCENT_COLOR;
	
	/// AppOption, Enables/Disables reading and using colors from playable items for UI controls
	static var COLORED_PLAYER = true;
	/// AppOption, Enables/Disables music caching and providing offline access to the app when there is no network connectivity
	static var OFFLINE_ACCESS = true;
	
	static var PRIMARY_TEXT_COLOR = WHITE_THEME.PRIMARY_TEXT_COLOR;
	static var SECONDARY_TEXT_COLOR = WHITE_THEME.SECONDARY_TEXT_COLOR;
	static var PLAYER_TITLE_COLOR = WHITE_THEME.PLAYER_TITLE_COLOR;
	
	static let IMAGES_BORDER_COLOR = UIColor(hex: "#D3D3D3");
	
	static let MUSIC_TRACKS_CACHE_FOLDER_NAME = "Music_Tracks";
	static let MUSIC_IMAGES_CACHE_FOLDER_NAME = "Music_Images";
	
	static var MUSIC_TRACKS_CACHE_FOLDER_PATH: String {
		get {
			if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
			{
				let musicTracksDirectoryPath = documentsDirectoryPath.appending("/\(Constants.MUSIC_TRACKS_CACHE_FOLDER_NAME)");
				return musicTracksDirectoryPath;
			}
			
			return "";
		}
	}
	
	static var MUSIC_IMAGES_CACHE_FOLDER_PATH: String {
		get {
			if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
			{
				let musicImagesDirectoryPath = documentsDirectoryPath.appending("/\(Constants.MUSIC_IMAGES_CACHE_FOLDER_NAME)");
				return musicImagesDirectoryPath;
			}
			
			return "";
		}
	}
	
	static func getCurrentApplicationDocoumentDirectory() -> String? {
		if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
		{
			return documentsDirectoryPath;
		}
		
		return nil;
	}
	
	static func createCacheFoldersIfDoesNotExist() {
		let fileManager = FileManager.default;
		
		if(!fileManager.fileExists(atPath: Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH)) {
			try? fileManager.createDirectory(atPath: Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH,
											 withIntermediateDirectories: false,
											 attributes: nil);
		}
		
		if(!fileManager.fileExists(atPath: Constants.MUSIC_IMAGES_CACHE_FOLDER_PATH)) {
			try? fileManager.createDirectory(atPath: Constants.MUSIC_IMAGES_CACHE_FOLDER_PATH,
											 withIntermediateDirectories: false,
											 attributes: nil);
		}
	}
	
	static let audioPlayerInitiatePlayBroadcastNotificationKey = "\(String(describing: Bundle.main.bundleIdentifier)).audioPlayerInitiatePlayBroadcastNotificationKey";
	static let audioPlayerStopAndClearPlayersBroadcastNotificationKey = "\(String(describing: Bundle.main.bundleIdentifier)).audioPlayerStopAndClearPlayersBroadcastNotificationKey";
	static let halfModalDimmedViewTappedBroadcastNotificationKey = "\(String(describing: Bundle.main.bundleIdentifier)).halfModalDimmedViewTappedBroadcastNotificationKey";
	static let trackLongPressedBroadcastNotificationKey = "\(String(describing: Bundle.main.bundleIdentifier)).trackLongPressedBroadcastNotificationKey";
	
	struct WHITE_THEME {
		static let PRIMARY_COLOR = UIColor(hex: "#FFFFFF");
		static let ACCENT_COLOR = UIColor(hex: "#E83223");
		
		static var PRIMARY_TEXT_COLOR = UIColor(hex: "#000000");
		static var SECONDARY_TEXT_COLOR = UIColor(hex: "#808080");
		static var PLAYER_TITLE_COLOR = UIColor(hex: "#FFFFFF");
	}
	
	struct BLACK_THEME {
		static let PRIMARY_COLOR = UIColor(hex: "#000000");
		static let ACCENT_COLOR = UIColor(hex: "#E83223");
		
		static var PRIMARY_TEXT_COLOR = UIColor(hex: "#FFFFFF");
		static var SECONDARY_TEXT_COLOR = UIColor(hex: "#808080");
		static var PLAYER_TITLE_COLOR = UIColor(hex: "#FFFFFF");
	}
	
	struct PURPLE_DARK_THEME {
		static let PRIMARY_COLOR = UIColor(hex: "#170a2d");
		static let ACCENT_COLOR = UIColor(hex: "#E83223");
		
		static var PRIMARY_TEXT_COLOR = UIColor(hex: "#FFFFFF");
		static var SECONDARY_TEXT_COLOR = UIColor(hex: "#808080");
		static var PLAYER_TITLE_COLOR = UIColor(hex: "#FFFFFF");
	}
}
