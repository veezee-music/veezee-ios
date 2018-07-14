//
//  HomePageItemType.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 3/1/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation

enum HomePageItemType: String, Codable {
	case Header;
	case Album;
	case Track;
	case Genre;
	
	case Spacer;
	case Divider;
}
