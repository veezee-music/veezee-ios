//
//  Content.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 1/27/18.
//  Copyright © 2018 veezee. All rights reserved.
//

import Foundation

struct HomePageItem : Codable {
	var type: HomePageItemType?;
	var title: String?;
	
	var headerList: [Header]?;
	var albumList: [Album]?;
	var trackList: [Track]?;
	var genreList: [Genre]?;
	
//	required init?(map: Map) {
//
//	}
//
//	func mapping(map: Map) {
//		self.type <- map["type"];
//		self.title <- map["title"];
//
//		self.trackList <- map["trackList"];
//		self.albumList <- map["albumList"];
//	}
}
