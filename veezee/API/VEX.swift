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
		
		static func playedTrack(track: PlayableItem, handler: @escaping () -> Void) {
			let url = "\(Constants.API_BASE_URL)/account/vex/played-track";
			let decoder = JSONDecoder();
			decoder.dateDecodingStrategy = .secondsSince1970;
			
			let params = ["track": track.dictionary];
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
		
	}
}
