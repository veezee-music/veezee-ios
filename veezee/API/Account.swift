//
//  User.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/23/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

extension API {
	class Account {
		
		static func processGoogleLogin(serverAuthCode: String, handler: @escaping (User?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/google/process-login";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["serverAuthCode": serverAuthCode];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<User>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, "Network connection is not possible.");
						return;
					}
					
					if code != 200 {
						// error
						handler(nil, "Google sign in is not available right now. Please use email to sign in/sign up.");
						return;
					}
					
					guard let value = response.result.value else {
						handler(nil, nil);
						return;
					}
					
					handler(value, nil);
			};
		}
		
		static func logIn(email: String, password: String, handler: @escaping (User?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/login";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["email": email, "password": password];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<User>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, "Network connection is not possible.");
						return;
					}
					
					if code != 200 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(nil, body["error"]);
							return;
						} catch {
							switch code {
							case 500:
								handler(nil, "There are some issues on our side. Please try again later.");
								return;
							case 530:
								handler(nil, "Account is created using Google. Please log in usign the Google login button.");
								return;
							case 401:
								handler(nil, "Email/Password is wrong or user does not exist.");
								return;
							case 404:
								handler(nil, "Resource was not found.");
								return;
							default:
								handler(nil, "Unknown Error");
								return;
							}
						}
					}
					
					guard let value = response.result.value else {
						handler(nil, nil);
						return;
					}
					
					handler(value, nil);
			};
		}
		
		static func register(name: String, email: String, password: String, handler: @escaping (User?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/register";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["name": name, "email": email, "password": password];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<User>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, "Network connection is not possible.");
						return;
					}
					
					if code != 200 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(nil, body["error"]);
							return;
						} catch {
							switch code {
							case 500:
								handler(nil, "There are some issues on our side. Please try again later.");
								return;
							case 530:
								handler(nil, "Account is created using Google. Please log in usign the Google login button.");
								return;
							case 404:
								handler(nil, "Resource was not found.");
								return;
							default:
								handler(nil, "Unknown Error");
								return;
							}
						}
					}
					
					guard let value = response.result.value else {
						handler(nil, nil);
						return;
					}
					
					handler(value, nil);
			};
		}
		
		static func validateLogin(token: String?, handler: @escaping (User?, String?, Bool?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/validate-login";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["token": token];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<User>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, nil, true);
						return;
					}
					
					if code != 200 {
						// error
						switch code {
						case 500:
							handler(nil, nil, false);
							return;
						case 504:
							handler(nil, nil, true);
							return;
						case 401:
							handler(nil, "Email/Password is wrong or user does not exist.", nil);
							return;
						case 404:
							handler(nil, "Resource was not found.", false);
							return;
						case 410:
							handler(nil, nil, false);
							return;
						default:
							handler(nil, nil, true);
							return;
						}
					}
					
					guard let value = response.result.value else {
						handler(nil, nil, nil);
						return;
					}
					
					handler(value, nil, nil);
			};
		}
		
		static func info(handler: @escaping (User?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/info";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.checkForToken()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<User>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, "Network connection is not possible.");
						return;
					}
					
					if code != 200 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(nil, body["error"]);
							return;
						} catch {
							switch code {
							case 500:
								handler(nil, "There are some issues on our side. Please try again later.");
								return;
							case 404:
								handler(nil, "Resource was not found.");
								return;
							default:
								handler(nil, "Unknown Error");
								return;
							}
						}
					}
					
					guard let value = response.result.value else {
						handler(nil, nil);
						return;
					}
					
					handler(value, nil);
			};
		}
		
	}
}

extension API.Account {
	class Playlists {
		
		static func new(title: String, handler: @escaping (Album?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/playlists/new";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["title": title];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<Album>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, "Network connection is not possible.");
						return;
					}
					
					if code != 201 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(nil, body["error"]);
							return;
						} catch {
							handler(nil, "Unknown Error");
							return;
						}
					}
					
					guard let value = response.result.value else {
						handler(nil, nil);
						return;
					}
					
					handler(value, nil);
			};
		}
		
		static func get(handler: @escaping ([Album]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/playlists/get";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<[Album]>) in
					
					guard let code = response.response?.statusCode else {
						handler(nil, "Network connection is not possible.");
						return;
					}
					
					if code != 200 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(nil, body["error"]);
							return;
						} catch {
							handler(nil, "Unknown Error");
							return;
						}
					}
					
					guard let value = response.result.value else {
						handler(nil, nil);
						return;
					}
					
					handler(value, nil);
			};
		}
		
		static func delete(_id: String, handler: @escaping (String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/playlists/delete/\(_id)";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			getHttpManager().request(URL(string: url)!, method: .delete)
				.validate()
				.response(completionHandler: { (response) in
					guard let code = response.response?.statusCode else {
						handler("Network connection is not possible.");
						return;
					}
					
					if code != 200 && code != 202 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(body["error"]);
							return;
						} catch {
							handler("Unknown Error");
							return;
						}
					}
					
					handler(nil);
				});
		}
		
	}
}

extension API.Account.Playlists {
	class Tracks {
		
		static func add(track: Track, playlist: Album, handler: @escaping (String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/playlists/tracks/add";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["track": track.dictionary, "playlist": playlist.dictionary] as [String : Any];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<Album>) in
					
					guard let code = response.response?.statusCode else {
						handler("Network connection is not possible.");
						return;
					}
					
					if code != 201 && code != 200 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(body["error"]);
							return;
						} catch {
							handler("Unknown Error");
							return;
						}
					}
					
					handler(nil);
			};
		}
		
	}
}

