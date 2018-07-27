//
//  MusicItem.swift
//  UNIVER30t-Native
//
//  Created by Vahid Amiri Motlagh on 1/31/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation

struct Album: Codable {
	var _id: [String:String]?;
	var id : String?;
	var title: String?;
	var artist: Artist?;
	var tracks: [Track]?;
	var image: String?;
	var colors = AlbumArtColor();
	var allTracks: [Track]?;
	
	enum CodingKeys: String, CodingKey {
		case genericAPIError
		case _id
		case id
		case title
		case artist
		case tracks
		case image
		case colors
		case allTracks
	}
	
	init() {
		
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self);
		
		id = (try? container.decode(._id, transformer: MongodbObjectIdCodableTransformer())) ?? nil;
		title = (try? container.decode(String?.self, forKey: .title)) ?? nil;
		artist = (try? container.decode(Artist?.self, forKey: .artist)) ?? nil;
		tracks = (try? container.decode([Track]?.self, forKey: .tracks)) ?? nil;
		image = (try? container.decode(String?.self, forKey: .image)) ?? nil;
		if(container.contains(.colors) && Constants.COLORED_PLAYER) {
			colors = try container.decode(AlbumArtColor.self, forKey: .colors);
		}
		allTracks = (try? container.decode([Track]?.self, forKey: .allTracks)) ?? nil;
	}
	
	func encode(to encoder: Encoder) throws {
		var container =  encoder.container(keyedBy: CodingKeys.self);
		
		try container.encode(id ?? "", forKey: ._id, transformer: MongodbObjectIdCodableTransformer());
		try container.encode(self.title, forKey: .title);
		try container.encode(self.artist, forKey: .artist);
		try container.encode(self.tracks, forKey: .tracks);
		try container.encode(self.image, forKey: .image);
		try container.encode(self.colors, forKey: .colors);
		try container.encode(self.allTracks, forKey: .allTracks);
	}
}
