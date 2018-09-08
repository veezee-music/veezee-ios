//
//  HeaderListItem.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/31/18.
//  Copyright © 2018 veezee. All rights reserved.
//

import Foundation

struct Header: Codable {
	var _id: [String:String]?;
	var id : String?;
	var image: String?;
	var type: String?;
	var title: String?;
	var artist: Artist?;
	var album: Album?;
	
	enum CodingKeys: String, CodingKey {
		case _id
		case id
		case image
		case type
		case title
		case artist
		case album
	}
	
	init() {
		
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self);
		
		id = try container.decode(._id, transformer: MongodbObjectIdCodableTransformer());
		image = try container.decode(String?.self, forKey: .image);
		type = try container.decode(String?.self, forKey: .type);
		title = try container.decode(String?.self, forKey: .title);
		
		artist = (try? container.decode(Artist?.self, forKey: .artist)) ?? nil;
		album = (try? container.decode(Album?.self, forKey: .album)) ?? nil;
	}
	
	func encode(to encoder: Encoder) throws {
		var container =  encoder.container(keyedBy: CodingKeys.self);
		
		try container.encode(id ?? "", forKey: ._id, transformer: MongodbObjectIdCodableTransformer());
	}
}
