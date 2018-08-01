//
//  BaseAudioPlayer.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 7/1/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import FreeStreamer
import MediaPlayer

typealias AudioPlayerState = FSAudioStreamState;
typealias AudioPlayerError = FSAudioStreamError;
typealias AudioPlayerTimes = FSStreamPosition;

open class BaseAudioPlayer: NSObject {
	
	public static let DEBUG_PRINT_CURRENT_STATE: Bool = false;
	
	public struct Notifications {
		static let willStartPlayingItem = "\(String(describing: Bundle.main.bundleIdentifier)).willStartPlayingItem";
		static let didChangeState = "\(String(describing: Bundle.main.bundleIdentifier)).didChangeState";
	}
	
	lazy var audioStreamConfig: FSStreamConfiguration = {
		let config = FSStreamConfiguration();
		config.cacheEnabled = true;
		config.cacheDirectory = Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH;
		
		return config;
	}();
	
	var audioStream: FSAudioStream? = nil;//FSAudioStream.init(configuration: self.audioStreamConfig);
	weak var delegate: AudioPlayerDelegate?;
	
	var queue = [PlayableItem]();
	
	var mode: AudioPlayerMode?;
	
	var state: AudioPlayerState?;
	var currentItemIndex: Int = 0;
	var currentItem: PlayableItem? {
		didSet {
			DispatchQueue.main.async {
				self.delegate?.onItemChange(item: self.currentItem, index: self.currentItemIndex);
				self.currentItemDuration = 0;
				self.currentItemProgression = 0;
				self.audioStream?.stop();
				self.audioStream = nil;
				self.timer?.invalidate();
				self.audioStream = FSAudioStream.init(configuration: self.audioStreamConfig);
				self.setupObservers();
				self.audioStream?.play(from: self.currentItem?.url);
				
				if(self.currentItem != nil) {
					API.VEX.playedTrack(trackId: self.currentItem!._id!, handler: {});
				}
			}
		}
	}
	
	var timer: Timer?;
	
	var currentItemDuration: TimeInterval = 0;
	var currentItemProgression: TimeInterval = 0;
	
	override init() {
		super.init();
		
//		let config = FSStreamConfiguration();
//		config.maxDiskCacheSize = 0;
		
//		self.setupObservers();
		
		self.registerMPNowPlayingInfoCenterActions();
	}
	
	deinit {
		self.timer?.invalidate();
	}
	
	func setupObservers() {
		audioStream?.onStateChange = {(state) -> Void in
			self.state = state;
			
			if(AudioPlayer.DEBUG_PRINT_CURRENT_STATE) {
				self.debugPrintCurrentState();
			}
			
			if(self.currentItemDuration == 0 && state == AudioPlayerState.fsAudioStreamPlaying) {
				self.currentItemDuration = TimeInterval(self.audioStream?.duration.playbackTimeInSeconds ?? 0);
				self.delegate?.onWillStartPlaying(item: self.currentItem, duration: self.currentItemDuration);
				NotificationCenter.default.post(name: Notification.Name(rawValue: AudioPlayer.Notifications.willStartPlayingItem), object: nil);
			}
			
			if(state == AudioPlayerState.fsAudioStreamEndOfFile && self.currentItem?.isOffline == false) {
				
				if let url: URL = self.currentItem?.url {
					
					let urlSHA1 = SHA1.hexString(from: url.absoluteString)?.lowercased().replacingOccurrences(of: " ", with: "");
					let originalCacheFileName = "FSCache-\(urlSHA1!)";
					
					self.delegate?.onFileCached(cachedFileName: originalCacheFileName);
					self.cacheCurrentItem(originalCacheFileName: originalCacheFileName);
				}
			}
			
			self.delegate?.onStateChange(state: state);
			NotificationCenter.default.post(name: Notification.Name(rawValue: AudioPlayer.Notifications.didChangeState), object: nil);
			
			self.updateMPNowPlayingInfoCenterWithCurrentItem();
			
		}
		
		audioStream?.onMetaDataAvailable = {(metaData) -> Void in
			self.delegate?.onMetaDataAvailable(metaData: metaData);
		}
		
		audioStream?.onFailure = {(streamingError, error) -> Void in
			self.delegate?.onFailure(streamingError: streamingError, error: error);
		}
		
		audioStream?.onCompletion = {
			self.delegate?.onCompletion();
			
			if(self.currentItemIndex == self.queue.count - 1) {
				self.delegate?.onQueueFinished();
			}
			
			self.nextOrStop();
		}
		
		self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(AudioPlayer.updateProgress), userInfo: nil, repeats: true);
	}
	
	open func registerMPNowPlayingInfoCenterActions() {
		let commandCenter = MPRemoteCommandCenter.shared()
		
		commandCenter.previousTrackCommand.isEnabled = true;
		commandCenter.previousTrackCommand.addTarget(self, action: #selector(self.prevOrRestart));
		
		commandCenter.nextTrackCommand.isEnabled = true
		commandCenter.nextTrackCommand.addTarget(self, action: #selector(self.nextOrStop));
		
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget(self, action: #selector(self.resume));
		
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget(self, action: #selector(self.pause));
		
		commandCenter.changePlaybackPositionCommand.isEnabled = true;
		commandCenter.changePlaybackPositionCommand.addTarget (handler: { event -> MPRemoteCommandHandlerStatus in
			let event = event as! MPChangePlaybackPositionCommandEvent
			self.seek(to: event.positionTime);
			return .success;
		});
	}
	
	var lastSavedProgress: TimeInterval = 0;
	@objc
	func updateProgress() {
		if(self.state != AudioPlayerState.fsAudioStreamPlaying) {
			return;
		}

		self.currentItemProgression = TimeInterval(self.audioStream?.currentTimePlayed.playbackTimeInSeconds ?? 0);
		self.delegate?.onPlaybackProgression(progression: self.currentItemProgression);
		self.updateMPNowPlayingInfoCenterWithCurrentItem();
	}
	
	@objc
	func nextOrStop() {
		if(self.mode?.contains(AudioPlayerMode.repeat) == true) {
			self.play(at: self.currentItemIndex);
			return;
		} else if(self.mode?.contains(AudioPlayerMode.shuffle) == true) {
			let randomIndex = Int(arc4random_uniform(UInt32(self.queue.count)));
			let tmpIndex = randomIndex;
			self.play(at: tmpIndex);
			return;
		}
		let tmpIndex = self.currentItemIndex + 1;
		if(self.queue.indices.contains(tmpIndex)) {
			self.play(at: tmpIndex);
		}
	}
	
	@objc
	func prevOrRestart() {
		if(self.mode?.contains(AudioPlayerMode.repeat) == true) {
			self.play(at: self.currentItemIndex);
			return;
		} else if(self.mode?.contains(AudioPlayerMode.shuffle) == true) {
			let randomIndex = Int(arc4random_uniform(UInt32(self.queue.count)));
			let tmpIndex = randomIndex;
			self.play(at: tmpIndex);
			return;
		}
		let tmpIndex = self.currentItemIndex - 1;
		if(self.queue.indices.contains(tmpIndex)) {
			self.play(at: tmpIndex);
		} else {
			self.play(at: 0);
		}
	}
	
	func play(at index: Int) {
		if(self.queue.indices.contains(index)) {
			self.currentItemIndex = index;
			self.currentItem = self.queue[index];
		}
	}
	
	func play(items: [PlayableItem], startAtIndex: Int) {
		self.queue = items;
		self.play(at: startAtIndex);
	}
	
	func stop() {
		/// Stop method must be executed on the main thread
		DispatchQueue.main.async {
			self.audioStream?.stop();
		}
	}
	
	@objc
	func pause() {
		self.audioStream?.pause();
	}
	
	@objc
	func resume() {
		// calling pause when play back is paused, will resume it
		self.audioStream?.pause();
	}
	
	func seek(to time: TimeInterval) {
		//let seconds = UInt32(time.truncatingRemainder(dividingBy: 60));
		//let minutes = UInt32(time / 60);
		
		let position = (time * 100) / self.currentItemDuration;
		
		self.audioStream?.seek(to: AudioPlayerTimes(minute: 0, second: 0, playbackTimeInSeconds: 0, position: Float(position / 100)));
	}
	
	func seek(percentage: CGFloat) {
		self.audioStream?.seek(to: AudioPlayerTimes(minute: 0, second: 0, playbackTimeInSeconds: 0, position: Float(percentage / 100)));
	}
	
	open func debugPrintCurrentState() {
		if let state = self.state {
			switch state {
			case AudioPlayerState.fsAudioStreamBuffering:
				print("buffering")
			case AudioPlayerState.fsAudioStreamPlaying:
				print("playing")
			case AudioPlayerState.fsAudioStreamPaused:
				print("paused")
			case AudioPlayerState.fsAudioStreamPlaybackCompleted:
				print("playback completed")
			case AudioPlayerState.fsAudioStreamRetrievingURL:
				print("retrieving url")
			case AudioPlayerState.fsAudioStreamStopped:
				print("stopped")
			case AudioPlayerState.fsAudioStreamFailed:
				print("failed")
			default:
				print("-other state")
			}
		}
	}
	
	/// Cache the current playing item in disk and also in the database
	/// Does nothing if item is already cached
	open func cacheCurrentItem(originalCacheFileName: String) {
		
	}
	
	func updateMPNowPlayingInfoCenterWithCurrentItem() {
		if let item = self.currentItem {
			MPNowPlayingInfoCenter.default().updateNow(
				with: item,
				duration: self.currentItemDuration,
				progression: self.currentItemProgression,
				playbackRate: 1);
		} else {
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nil;
		}
	}
	
}

protocol AudioPlayerDelegate: AnyObject {
	
	func onStateChange(state: AudioPlayerState);
	func onItemChange(item: PlayableItem?, index: Int);
	func onWillStartPlaying(item: PlayableItem?, duration: TimeInterval);
	func onPlaybackProgression(progression: TimeInterval);
	func onMetaDataAvailable(metaData: [AnyHashable: Any]?);
	func onFailure(streamingError: AudioPlayerError, error: String?);
	func onFileCached(cachedFileName: String);
	func onCompletion();
	func onQueueFinished();
	
}

public struct AudioPlayerMode: OptionSet {
	/// The raw value describing the mode.
	public let rawValue: UInt
	
	/// Initializes an `AudioPlayerMode` from a `rawValue`.
	///
	/// - Parameter rawValue: The raw value describing the mode.
	public init(rawValue: UInt) {
		self.rawValue = rawValue
	}
	
	/// In this mode, player's queue will be played as given.
	public static let normal = AudioPlayerMode(rawValue: 0)
	
	/// In this mode, player's queue is shuffled randomly.
	public static let shuffle = AudioPlayerMode(rawValue: 0b001)
	
	/// In this mode, the player will continuously play the same item over and over.
	public static let `repeat` = AudioPlayerMode(rawValue: 0b010)
	
	/// In this mode, the player will continuously play the same queue over and over.
	/// Not currently used
	public static let repeatAll = AudioPlayerMode(rawValue: 0b100)
}

extension MPNowPlayingInfoCenter {
	/// Updates the MPNowPlayingInfoCenter with the latest information on a `PlayableItem`.
	///
	/// - Parameters:
	///   - item: The item that is currently played.
	///   - duration: The item's duration.
	///   - progression: The current progression.
	///   - playbackRate: The current playback rate.
	func updateNow(with item: PlayableItem, duration: TimeInterval?, progression: TimeInterval?, playbackRate: Float) {
		var info = [String: Any]()
		if let title = item.title {
			info[MPMediaItemPropertyTitle] = title
		}
		if let artist = item.artist {
			info[MPMediaItemPropertyArtist] = artist
		}
		if let album = item.album {
			info[MPMediaItemPropertyAlbumTitle] = album
		}
		//if let trackCount = item.trackCount {
		//	info[MPMediaItemPropertyAlbumTrackCount] = trackCount
		//}
		//if let trackNumber = item.trackNumber {
		//	info[MPMediaItemPropertyAlbumTrackNumber] = trackNumber
		//}
		if let artwork = item.artworkImage {
			info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
		}
		if let duration = duration {
			info[MPMediaItemPropertyPlaybackDuration] = duration
		}
		if let progression = progression {
			info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progression
		}
		info[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
		
		nowPlayingInfo = info
	}
}
