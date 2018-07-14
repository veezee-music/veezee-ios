//
//  AlbumArtColor.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 3/7/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

struct AlbumArtColor: Codable {
	var primaryColor : UIColor?;
	var accentColor: UIColor?
	
	enum CodingKeys: String, CodingKey {
		case primaryColor
		case accentColor
	}
	
	init(primaryColor: UIColor, accentColor: UIColor) {
		self.primaryColor = primaryColor;
		self.accentColor = accentColor;
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		primaryColor = (try? container.decode(.primaryColor, transformer: HexColorTransformer())) ?? nil;
		accentColor = (try? container.decode(.accentColor, transformer: HexColorTransformer())) ?? nil;
	}
	
	func encode(to encoder: Encoder) throws {
		var container =  encoder.container(keyedBy: CodingKeys.self);
		
		try container.encode(self.primaryColor!, forKey: .primaryColor, transformer: HexColorTransformer());
		try container.encode(self.accentColor!, forKey: .accentColor, transformer: HexColorTransformer());
	}
}

