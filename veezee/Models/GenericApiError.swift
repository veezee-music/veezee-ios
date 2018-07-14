////
////  GenericApiResponse.swift
////  veezee
////
////  Created by Vahid Amiri Motlagh on 5/19/18.
////  Copyright © 2018 veezee-music. All rights reserved.
////
//
//import Foundation
//
//struct GenericAPIError: Decodable {
//	var error : String?;
//	var code: Int?;
//	
//	enum CodingKeyss: String, CodingKey {
//		case error
//		case code
//	}
//	
//	init(error: String) {
//		self.error = error;
//	}
//	
//	init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeyss.self);
//		
//		error = (try? container.decode(String?.self, forKey: .error)) ?? nil;
//		code = (try? container.decode(Int?.self, forKey: .code)) ?? nil;
//	}
//}
