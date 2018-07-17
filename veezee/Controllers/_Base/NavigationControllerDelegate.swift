//
//  NavigationControllerDelegate.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/30/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation

protocol NavigationControllerDelegate: AnyObject {
	func navigateToVCFor(album: Album);
	func navigateToVCFor(tracksList: [Track]);
	func navigateToVCFor(albumsList: [Album]);
	func navigateToVCFor(playLists: [Album]);
}
