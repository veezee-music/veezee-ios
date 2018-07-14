//
//  HalfModalViewController.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/20/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit

class HalfModalViewController : UIViewController {
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.onHalfModalDimmedViewTappedOrPushed), name: NSNotification.Name(rawValue: Constants.halfModalDimmedViewTappedBroadcastNotificationKey), object: nil);
	}
	
	@objc
	func onHalfModalDimmedViewTappedOrPushed() {
		self.dismiss(animated: true, completion: nil);
	}
	
}
