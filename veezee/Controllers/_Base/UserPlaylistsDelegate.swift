//
//  UserPlaylistsDelegate.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/30/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation

protocol UserPlaylistsDelegate: AnyObject {
	func playlistSelected(playlist: Album);
	func trackAddedToPlaylist(playlist: Album);
}
