//
//  AudioItem.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 12/03/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

//import AVFoundation
//import UIKit
//import MediaPlayer
//
//// MARK: - AudioItem
//
///// An `AudioItem` instance contains every piece of information needed for an `AudioPlayer` to play.
/////
///// URLs can be remote or local.
//open class AudioItem: NSObject {
//    /// Returns the available qualities.
//    public var url: URL!
//
//    // MARK: Initialization
//
//    /// Initializes an `AudioItem`.
//    ///
//    /// - Parameter soundURLs: The URLs of the sound associated with its quality wrapped in a `Dictionary`.
//	public init?(url: URL) {
//        super.init()
//
//		self.url = url
//    }
//
//    // MARK: Additional properties
//
//    /// The artist of the item.
//    ///
//    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
//    @objc open dynamic var artist: String?
//
//    /// The title of the item.
//    ///
//    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
//    @objc open dynamic var title: String?
//
//    /// The album of the item.
//    ///
//    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
//    @objc open dynamic var album: String?
//
//    ///The track count of the item's album.
//    ///
//    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
//    @objc open dynamic var trackCount: NSNumber?
//
//    /// The track number of the item in its album.
//    ///
//    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
//    @objc open dynamic var trackNumber: NSNumber?
//
//    /// The artwork image of the item.
//    open var artworkImage: UIImage? {
//        get {
//			return artwork?.image(at: imageSize ?? CGSize(width: 512, height: 512))
//        }
//        set {
//			imageSize = newValue?.size
//			artwork = newValue.map { image in
//				return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
//			}
//        }
//    }
//
//    /// The artwork image of the item.
//    ///
//    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
//    @objc open dynamic var artwork: MPMediaItemArtwork?
//
//    /// The image size.
//    private var imageSize: CGSize?
//
//    // MARK: Metadata
//
//    /// Parses the metadata coming from the stream/file specified in the URL's. The default behavior is to set values
//    /// for every property that is nil. Customization is available through subclassing.
//    ///
//    /// - Parameter items: The metadata items.
//    open func parseMetadata(_ items: [AVMetadataItem]) {
//        items.forEach {
//            if let commonKey = $0.commonKey {
//                switch commonKey {
//                case AVMetadataKey.commonKeyTitle where title == nil:
//                    title = $0.value as? String
//                case AVMetadataKey.commonKeyArtist where artist == nil:
//                    artist = $0.value as? String
//                case AVMetadataKey.commonKeyAlbumName where album == nil:
//                    album = $0.value as? String
//                case AVMetadataKey.id3MetadataKeyTrackNumber where trackNumber == nil:
//                    trackNumber = $0.value as? NSNumber
//                case AVMetadataKey.commonKeyArtwork where artwork == nil:
//                    artworkImage = ($0.value as? Data).flatMap { UIImage(data: $0) }
//                default:
//                    break
//                }
//            }
//        }
//    }
//}
