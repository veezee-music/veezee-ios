//
//  ProgressHUD.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 5/20/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import PKHUD

class ProgressHUD: PKHUD {
	
	convenience init(superView: UIView) {
		self.init(viewToPresentOn: superView);
		self.contentView = PKHUDRotatingImageView(image: UIImage(named: "progress"));
	}
	
}

extension HUD {
	public static func flashProgress(onView view: UIView? = nil, delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
		HUD.show(.rotatingImage(UIImage(named: "progress")), onView: view)
		HUD.hide(afterDelay: delay, completion: completion)
	}
	
	public static func showProgress(onView view: UIView? = nil) {
		PKHUD.sharedHUD.contentView = PKHUDRotatingImageView(image: UIImage(named: "progress"));
		PKHUD.sharedHUD.show(onView: view)
	}
}
