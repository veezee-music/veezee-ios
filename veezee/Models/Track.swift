//
//  TrackListItem.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/9/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation

struct Track: Codable {
	var _id: [String:String]?;
	var id: String?;
	var title: String?;
	var fileName: String?;
	var originalFileName: String?;
	var album: Album?;
	var image: String?;
	var colors = AlbumArtColor();
	
	enum CodingKeys: String, CodingKey {
		case _id
		case id
		case title
		case fileName
		case originalFileName
		case album
		case image
		case colors
	}
	
	init() {
		
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self);
		id = try container.decode(._id, transformer: MongodbObjectIdCodableTransformer());
		title = try container.decode(String?.self, forKey: .title);
		fileName = try container.decode(String?.self, forKey: .fileName);
		originalFileName = try container.decode(String?.self, forKey: .originalFileName);
		album = (try? container.decode(Album?.self, forKey: .album)) ?? nil;
		image = (try? container.decode(String?.self, forKey: .image)) ?? nil;
		if(container.contains(.colors) && Constants.COLORED_PLAYER) {
			colors = try container.decode(AlbumArtColor.self, forKey: .colors);
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container =  encoder.container(keyedBy: CodingKeys.self);
		
		try container.encode(id ?? "", forKey: ._id, transformer: MongodbObjectIdCodableTransformer());
		try container.encode(self.title, forKey: .title);
		try container.encode(self.fileName, forKey: .fileName);
		try container.encode(self.originalFileName, forKey: .originalFileName);
		try container.encode(self.album, forKey: .album);
		try container.encode(self.image, forKey: .image);
		try container.encode(self.colors, forKey: .colors);
	}
}
