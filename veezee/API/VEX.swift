//
//  PersonalMusicExperience.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/30/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

extension API {
	class VEX {
		
		static func playedTrack(trackId: String, handler: @escaping () -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/vex/played-track";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["trackId": trackId];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
				.validate()
				.responsePropertyList(completionHandler: { (response) in
					
					guard let code = response.response?.statusCode else {
						handler();
						return;
					}
					
					if code != 200 {
						// error
						
					}
					
					handler();
				});
		}
		
		static func deleteTrackFromHistory(trackId: String?, handler: @escaping (String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/vex/delete-track-from-history";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			if(trackId == nil) {
				handler("Track id is nil.");
			}
			
			let params = ["trackId": trackId!];
			let headers: HTTPHeaders = [:];
			
			getHttpManager().request(URL(string: url)!, method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers)
				.validate()
				.responsePropertyList(completionHandler: { (response) in
					
					guard let code = response.response?.statusCode else {
						handler("Network connection is not possible.");
						return;
					}
					
					if code != 200 {
						// error
						do {
							let body = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String: String];
							handler(body["error"]);
							return;
						} catch {
							switch code {
							case 500:
								handler("There are some issues on our side. Please try again later.");
								return;
							case 404:
								handler("Resource was not found.");
								return;
							default:
								handler("Unknown Error");
								return;
							}
						}
					}
					
					handler(nil);
				});
		}
		
		static func tracksHistory(limit: Int, handler: @escaping ([Track]?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/vex/user-tracks-history";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params: [String: AnyObject] = ["limit": limit as AnyObject];
			
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
		
	}
}
