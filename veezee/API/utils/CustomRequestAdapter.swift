//
//  CustomRequestAdapter.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/28/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift
import DeviceKit

class CustomRequestAdapter: RequestAdapter {
	
	private let keychain = KeychainSwift();
	
	func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
		var urlRequest = urlRequest;
		
		let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
		let appBuildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String;
		let osVersion: String = UIDevice.current.systemVersion as String;
		let device = Device();

		urlRequest.setValue("veezee-\(appVersion):\(appBuildNumber)/iOS-\(osVersion)/\(device)", forHTTPHeaderField: "X-Requested-With");
		urlRequest.timeoutInterval = Constants.API_TIME_OUT;
		
		let token = self.keychain.get("token");
		if(token != nil) {
			urlRequest.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization");
		}
		
		return urlRequest;
	}
}

extension Request {
//	public static func AuthSaver() -> ResponseSerializer<Bool, NSError> {
//		return ResponseSerializer { request, response, data, error in
//			guard error == nil else { return .Failure(error!) }
//
//			if let auth = response?.allHeaderFields["Authorization"] as? String {
//				Router.OAuthToken = auth // this uses a didset on the Router to save to keychain
//			}
//
//			return .Success(true)
//		}
//	}
	
	public func checkForToken() -> Self {
		if let token = response?.allHeaderFields["Authorization"] as? String {
			let keychain = KeychainSwift();
			keychain.set(extractAuthorizationToken(token: token), forKey: "token");
		}
		
		return self;
	}
}

func getHttpManager() -> SessionManager {
	let sessionManager = Alamofire.SessionManager.default;
	sessionManager.adapter = CustomRequestAdapter();
	
	return sessionManager;
}
