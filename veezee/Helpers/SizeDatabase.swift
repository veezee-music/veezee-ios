////
////  SizesDatabase.swift
////  bxpi
////
////  Created by Vahid Amiri Motlagh on 2/9/18.
////  Copyright © 2018 UNIVER30t Network. All rights reserved.
////
//
//import Foundation
//import UIKit
//import DeviceKit
//
//final class SizeDatabase {
//	static let sharedInstance = SizeDatabase();
//	
//	var heightDb: DeviceSpecificBaseSize;
//	var widthDb: DeviceSpecificBaseSize;
//	
//	private init() {
//		
//		let device = Device();
//		if(device.isOneOf(DeviceCategories.ipads10_5inch)) {
//			self.heightDb = iPad_10_5();
//			self.widthDb = iPad_10_5();
//		} else if(device.isOneOf(DeviceCategories.ipads9_7inch)) {
//			self.heightDb = iPad_9_7();
//			self.widthDb = iPad_9_7();
//		} else if(device.isOneOf(DeviceCategories.ipads12_9inch)) {
//			self.heightDb = iPad_12_9();
//			self.widthDb = iPad_12_9();
//		} else {
//			self.heightDb = iPad_10_5();
//			self.widthDb = iPad_10_5();
//		}
//	}
//}
//
//class DeviceSpecificBaseSize {
//	var _20 : CGFloat = 30;
//	var _100 : CGFloat = 100;
//}
//
//class iPad_10_5 : DeviceSpecificBaseSize {
//	override var _20 : CGFloat { get { return 20 } set {} }
//	override var _100 : CGFloat { get { return 100 } set {} }
//}
//
//class iPad_9_7 : DeviceSpecificBaseSize {
//	override var _20 : CGFloat { get { return 30 } set {} }
//	override var _100 : CGFloat { get { return 100 } set {} }
//}
//
//class iPad_12_9 : DeviceSpecificBaseSize {
////	override var _20 : CGFloat { get { return 50 } set {} }
//	override var _100 : CGFloat { get { return 100 } set {} }
//}

