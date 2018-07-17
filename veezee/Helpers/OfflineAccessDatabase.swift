//
//  OfflineAccessDatabase.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 4/18/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

final public class OfflineAccessDatabase: NSObject {
	
	static let sharedInstance = OfflineAccessDatabase();
	var database: Database?;

	public override init() {
		super.init();
		
		self.initDatabase();
	}
	
	func initDatabase() {
		do {
			self.database = try Database(name: "offline_access_library");
		} catch {}
	}
	
}
