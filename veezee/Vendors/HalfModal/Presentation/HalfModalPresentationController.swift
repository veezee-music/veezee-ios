//
//  HalfModalPresentationController.swift
//  HalfModalPresentationController
//
//  Created by Martin Normark on 17/01/16.
//  Copyright © 2016 martinnormark. All rights reserved.
//

import UIKit

public class HalfModalPresentationController : UIPresentationController {
    var isMaximized: Bool = false
	
    var _dimmingView: UIView?
    var dimmingView: UIView {
        if let dimmedView = _dimmingView {
            return dimmedView
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        // Blur Effect
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark);
		let blurEffectView = UIVisualEffectView(effect: blurEffect);
		blurEffectView.frame = view.bounds;
		view.addSubview(blurEffectView);
        
        // Vibrancy Effect
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect);
		let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect);
		vibrancyEffectView.frame = view.bounds;
        
        // Add the vibrancy view to the blur view
		blurEffectView.contentView.addSubview(vibrancyEffectView);
        
		_dimmingView = view;
		
		view.isUserInteractionEnabled = true;
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.dimmedViewTapped));
		view.addGestureRecognizer(tap);
        
		return view;
    }
	
	@objc
	func dimmedViewTapped() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.halfModalDimmedViewTappedBroadcastNotificationKey), object: self);
	}
    
    func adjustToFullScreen() {
        if let presentedView = presentedView, let containerView = self.containerView {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                presentedView.frame = containerView.frame
                
                if let navController = self.presentedViewController as? UINavigationController {
                    self.isMaximized = true
                    
                    navController.setNeedsStatusBarAppearanceUpdate()
                    
                    // Force the navigation bar to update its size
                    navController.isNavigationBarHidden = true
                    navController.isNavigationBarHidden = false
                }
                }, completion: nil)
        }
    }
    
	override public var frameOfPresentedViewInContainerView: CGRect {
		if(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
			return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height)
		} else {
			if(isDeviceLandscape()) {
				return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height)
			} else {
				return CGRect(x: 0, y: containerView!.bounds.height / 2, width: containerView!.bounds.width, height: containerView!.bounds.height / 2)
			}
		}
    }
    
	override public func presentationTransitionWillBegin() {
        let dimmedView = dimmingView
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            
            dimmedView.alpha = 0
            containerView.addSubview(dimmedView)
            dimmedView.addSubview(presentedViewController.view)
            
            coordinator.animate(alongsideTransition: { context in
                dimmedView.alpha = 1
                self.presentingViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        }
    }
    
	override public func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmingView.alpha = 0
                self.presentingViewController.view.transform = CGAffineTransform.identity
            }, completion: { (completed) -> Void in
				// done dismissing animation
            })
            
        }
    }
    
	override public func dismissalTransitionDidEnd(_ completed: Bool) {
        // dismissal did end
        
        if completed {
            dimmingView.removeFromSuperview()
            _dimmingView = nil
            
            isMaximized = false
        }
    }
}

protocol HalfModalPresentable { }

extension HalfModalPresentable where Self: UIViewController {
    func maximizeToFullScreen() -> Void {
        if let presetation = navigationController?.presentationController as? HalfModalPresentationController {
            presetation.adjustToFullScreen()
        }
    }
}

extension HalfModalPresentable where Self: UINavigationController {
    func isHalfModalMaximized() -> Bool {
        if let presentationController = presentationController as? HalfModalPresentationController {
            return presentationController.isMaximized
        }
        
        return false
    }
}
