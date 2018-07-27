//
//  PlayableList.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/12/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

open class PlayableItem: Codable {
	var _id: String?;
	var title: String?;
	var artist: String?;
	var artistObj: Artist?;
	var album: String?;
	var albumObj: Album?;
	var imageUrl: String?;
	var artworkImage: UIImage?;
	var colors = AlbumArtColor();
	var fileName: String?;
	var url: URL?;
	
	var isOffline: Bool = false;
	
	enum CodingKeys: String, CodingKey {
		case _id
		case title
		case artist
		case artistObj
		case album
		case albumObj
		case imageUrl
		case colors
		case fileName
		case url
	}

	init(url: URL) {
		self.url = url;
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self);
		_id = try container.decode(._id, transformer: MongodbObjectIdCodableTransformer());
		title = try container.decode(String?.self, forKey: .title);
		artist = try container.decode(String?.self, forKey: .artist);
		artistObj = try container.decode(Artist?.self, forKey: .artistObj);
		album = (try? container.decode(String?.self, forKey: .album)) ?? nil;
		albumObj = (try? container.decode(Album?.self, forKey: .albumObj)) ?? nil;
		imageUrl = (try? container.decode(String?.self, forKey: .imageUrl)) ?? nil;
		colors = (try container.decode(AlbumArtColor.self, forKey: .colors));
		fileName = (try? container.decode(String?.self, forKey: .fileName)) ?? nil;
		url = (try? container.decode(URL?.self, forKey: .url)) ?? nil;
	}
	
	public func encode(to encoder: Encoder) throws {
		var container =  encoder.container(keyedBy: CodingKeys.self);

		try container.encode(_id ?? "", forKey: ._id, transformer: MongodbObjectIdCodableTransformer());
		try container.encode(self.title, forKey: .title);
		try container.encode(self.artist, forKey: .artist);
		try container.encode(self.artistObj, forKey: .artistObj);
		try container.encode(self.albumObj, forKey: .albumObj);
		try container.encode(self.album, forKey: .album);
		try container.encode(self.imageUrl, forKey: .imageUrl);
		try container.encode(self.colors, forKey: .colors);
		try container.encode(self.fileName, forKey: .fileName);
		try container.encode(self.url, forKey: .url);
	}
}

