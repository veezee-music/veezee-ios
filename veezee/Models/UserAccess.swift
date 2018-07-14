//
//  User.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 3/23/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation

struct UserAccess: Codable {
	var type: String?;
	var playsAllowedPerDay: Int?;
	var expiresIn: Date?;
	
	enum CodingKeys: String, CodingKey {
		case type
		case playsAllowedPerDay
		case expiresIn
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self);
		
		type = (try? container.decode(String?.self, forKey: .type)) ?? nil;
		playsAllowedPerDay = (try? container.decode(Int?.self, forKey: .playsAllowedPerDay)) ?? nil;
		expiresIn = (try? container.decode(Date?.self, forKey: .expiresIn)) ?? nil;
	}
	
	func encode(to encoder: Encoder) throws {
		var container =  encoder.container(keyedBy: CodingKeys.self);
		
		try container.encode(self.type, forKey: .type);
		try container.encode(self.playsAllowedPerDay, forKey: .playsAllowedPerDay);
		try container.encode(self.expiresIn, forKey: .expiresIn);
	}
}

