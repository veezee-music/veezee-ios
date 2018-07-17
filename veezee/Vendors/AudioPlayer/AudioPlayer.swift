//
//  FreeStreamerAudioPlayer.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 7/1/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import Kingfisher
import CouchbaseLiteSwift


final public class AudioPlayer: BaseAudioPlayer {
	
	static let shared = AudioPlayer();
	
	override init() {
		super.init();
	}
	
	override public func cacheCurrentItem(originalCacheFileName: String) {
		super.cacheCurrentItem(originalCacheFileName: originalCacheFileName);
		
		if(!Constants.OFFLINE_ACCESS || self.currentItem?.isOffline == true) {
			return;
		}
		
		// create a new file name
		let fileName = self.currentItem!._id;
		let fileExtension = self.currentItem!.url!.pathExtension;
		let newCacheFileName = "\(fileName!).\(fileExtension)";
		
		// rename the old file to the new name
		let documentDirectory = URL.createFrom(localOrRemoteAddress: Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH);
		let originPath = documentDirectory.appendingPathComponent(originalCacheFileName);
		let destinationPath = documentDirectory.appendingPathComponent(newCacheFileName);
		try? FileManager.default.moveItem(at: originPath, to: destinationPath);
		
		self.currentItem?.isOffline = true;
		self.currentItem?.fileName = newCacheFileName;
		let cacheUrl = URL(fileURLWithPath: Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH.appending("/").appending(newCacheFileName));
		
		if self.currentItem?.imageUrl != nil {
			var imageFileNameWithExtension: String? = nil;
			let imageUrl = URL(string: (self.currentItem?.imageUrl)!);
			KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: imageUrl!), options: nil, progressBlock: nil) {
				(image, error, cacheType, imageURL) -> () in
				var imagePath = Constants.MUSIC_IMAGES_CACHE_FOLDER_PATH.appending("/\(fileName!)");
				
				if(imageUrl?.pathExtension == "jpg") {
					if let data = UIImagePNGRepresentation(image!) {
						imagePath = imagePath.appending(".jpg");
						imageFileNameWithExtension = "\(fileName!).jpg";
						let url = URL(fileURLWithPath: imagePath);
						try? data.write(to: url);
					}
				} else if(imageUrl?.pathExtension == "png") {
					if let data = UIImageJPEGRepresentation(image!, 1.0) {
						imagePath = imagePath.appending(".png");
						imageFileNameWithExtension = "\(fileName!).png";
						let url = URL(fileURLWithPath: imagePath);
						try? data.write(to: url);
					}
				}
				
				let originImageUrl = self.currentItem?.imageUrl;
				// save the playableItem in the db
				self.currentItem?.imageUrl = imageFileNameWithExtension;
				
				let playableItemEncoded = self.currentItem.dictionary;
				let offlineDocument = MutableDocument(id: self.currentItem?._id!, data: playableItemEncoded);
				try! OfflineAccessDatabase.sharedInstance.database?.saveDocument(offlineDocument);
				
				self.currentItem?.imageUrl = originImageUrl;
				
				self.currentItem?.url = cacheUrl;
			};
		} else {
			let playableItemEncoded = self.currentItem.dictionary;
			let offlineDocument = MutableDocument(id: self.currentItem?._id!, data: playableItemEncoded);
			try! OfflineAccessDatabase.sharedInstance.database?.saveDocument(offlineDocument);
			
			self.currentItem?.url = cacheUrl;
		}
		
		
	}
	
}
