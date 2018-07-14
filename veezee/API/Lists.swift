//
//  Lists.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 2/11/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

extension API {
	class Lists {
		
		static func home(handler: @escaping ([HomePageItem]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/home-page-collection";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			getHttpManager().request(URL(string: url)!, method: .get)
				.validate()
				.checkForToken()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<[HomePageItem]>) in
					
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
		
//		static func fetchAlbums(handler: @escaping ([Album]?, String?) -> Void) {
//			let url = "\(Constants.API_BASE_URL)/get/albums";
//			let decoder = JSONDecoder();
//			decoder.dateDecodingStrategy = .secondsSince1970;
//
//			getHttpManager().request(URL(string: url)!, method: .get)
//				.validate()
//				.checkForToken()
//				.responseDecodableObject(decoder: decoder) { (response: DataResponse<[Album]>) in
//
//					guard let code = response.response?.statusCode else {
//						handler(nil, "Network connection is not possible.");
//						return;
//					}
//
//					if code != 200 {
//						// error
//						do {
//							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
//							handler(nil, body["error"]);
//							return;
//						} catch {
//							switch code {
//							case 500:
//								handler(nil, "There are some issues on our side. Please try again later.");
//								return;
//							case 404:
//								handler(nil, "Resource was not found.");
//								return;
//							default:
//								handler(nil, "Unknown Error");
//								return;
//							}
//						}
//					}
//
//					guard let value = response.result.value else {
//						handler(nil, nil);
//						return;
//					}
//
//					handler(value, nil);
//			};
//		}
		
		static func search(q: String, handler: @escaping ([HomePageItem]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/search";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params: [String: AnyObject] = ["q": q as AnyObject];
			
			getHttpManager().request(URL(string: url)!, method: .get, parameters: params)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<[HomePageItem]>) in
					
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
		
		static func albums(lastId: String, handler: @escaping ([Album]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/albums";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params: [String: AnyObject] = ["lastId": lastId as AnyObject];
			
			getHttpManager().request(URL(string: url)!, method: .get, parameters: params)
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
		
		static func playlists(lastId: String, handler: @escaping ([Album]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/playlists";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params: [String: AnyObject] = ["lastId": lastId as AnyObject];
			
			getHttpManager().request(URL(string: url)!, method: .get, parameters: params)
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
		
		static func tracks(lastId: String, handler: @escaping ([Track]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/tracks";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params: [String: AnyObject] = ["lastId": lastId as AnyObject];
			
			getHttpManager().request(URL(string: url)!, method: .get, parameters: params)
				.validate()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<[Track]>) in

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
		
		static func latestAlbumArts(handler: @escaping ([String], String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/latest-album-arts";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			getHttpManager().request(URL(string: url)!, method: .get)
				.validate()
				.response(completionHandler: { (response) in
					guard let code = response.response?.statusCode else {
						handler([], "Network connection is not possible.");
						return;
					}
					
					if code == 200 {
						do {
							if let list = try JSONSerialization.jsonObject(with: response.data!, options: []) as? Array<[String : Any]> {
								var imagesList = [String]();
								for item in list {
									if let imageUrl = item["image"] as? String {
										imagesList.append(imageUrl);
									}
								}
								handler(imagesList, nil);
								return;
							}
						} catch {
							handler([], nil);
						}
					}
					
					handler([], nil);
				});
		}
		
		static func latestSearchTrends(handler: @escaping ([String], String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/latest-search-trends";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			getHttpManager().request(URL(string: url)!, method: .get)
				.validate()
				.response(completionHandler: { (response) in
					guard let code = response.response?.statusCode else {
						handler([], "Network connection is not possible.");
						return;
					}
					
					if code == 200 {
						do {
							if let list = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String] {
								handler(list, nil);
								return;
							}
						} catch {
							handler([], nil);
						}
					}
					
					handler([], nil);
				});
		}
		
	}
}
