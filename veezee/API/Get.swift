//
//  Get.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/7/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

extension API {
	class Get {
		
		static func album(_id: String, handler: @escaping (Album?, String?) -> Void) {
			let url = "\(Constants.API_BASE_URL)/get/album/\(_id)";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			getHttpManager().request(URL(string: url)!, method: .get)
				.validate()
				.checkForToken()
				.responseDecodableObject(decoder: decoder) { (response: DataResponse<Album>) in
					
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
