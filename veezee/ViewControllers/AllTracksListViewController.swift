//
//  AllTracksListViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 6/5/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import PKHUD

class AllTracksListViewController: _BasePageViewController {
	
	var albumsList = [Album]();
	var tracksList = [Track]();
	var playableList = [PlayableItem]();
	
	let insetSize: CGFloat = 15;
	
	lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = self.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = self.insetSize;
		// enable for ipad
//		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: self.insetSize, left: self.insetSize, bottom: self.insetSize, right: self.insetSize);
		
		return collectionViewFlowLayout;
	}();
	
	lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout);
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.isPagingEnabled = false;
		collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
		collectionView.register(TracksForAlbumCollectionViewCell.self, forCellWithReuseIdentifier: TracksForAlbumCollectionViewCell.ID);
		collectionView.register(TrackInTracksListViewCell.self, forCellWithReuseIdentifier: TrackInTracksListViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}();
	
	var isLoading = false;
	var canLoadMore = true;
	
//	var cardSize: CGSize = .zero;
	
	init() {
		super.init(nibName: nil, bundle: nil);
		
		self.title = "Tracks";
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		
		self.loadTracks();
//
//		if(self.device.isPad) {
//			let width = (self.view.frame.width / 4) - 20;
//			self.cardSize = CGSize(width: width, height: width + 50);
//		} else {
//			let width = self.view.frame.width;
//			self.cardSize = CGSize(width: width, height: width + 50);
//		}
		
		self.view.addSubview(self.collectionView);
		self.collectionView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(0)
			make.bottom.equalTo(0)
			make.left.right.equalTo(0);
		});
		
		self.initializeBottomPlayer();
		
	}
	
	override func shouldLeaveNavigationTitleUnchanged() -> Bool {
		return true;
	}
	
	private func sendPlayBroadcastNotification(playableList: [PlayableItem], currentPlayableItemIndex: Int) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : playableList, "currentPlayableItemIndex": currentPlayableItemIndex]);
	}
	
	func loadTracks(lastId: String = "0") {
		self.isLoading = true;
		if(lastId == "0") {
			HUD.showProgress();
		}
		API.Lists.tracks(lastId: lastId) { (tracks, errorMessage) in
			self.isLoading = false;
			HUD.hide(animated: true);
			if(tracks != nil && tracks!.count > 0) {
				for n in tracks! {
					self.tracksList.append(n);
				}
				self.createAlbumsListFrom(tracksList: tracks!);
			} else {
				self.canLoadMore = false;
			}
		}
	}
	
	func createAlbumsListFrom(tracksList: [Track]) {
		let oldAlbumsCount = self.albumsList.count;
		for track in tracksList {
			if(track.album == nil) {
				continue;
			}

			if(self.albumsList.last?.id != track.album?.id) {
				// push the track album to the albums list as the last album in the albumsList is not this album
				var album = track.album!;
				album.tracks = [Track]();
				album.allTracks = [Track]();
				album.allTracks!.append(track);
				
				self.albumsList.append(album);
			} else {
				// push the track to the last album in the albumsList
//				if(self.albumsList[self.albumsList.count - 1].tracks!.count < 6) {
//					self.albumsList[self.albumsList.count - 1].tracks!.append(track);
//				}
				self.albumsList[self.albumsList.count - 1].allTracks!.append(track);
			}
		}
		
		for i in oldAlbumsCount..<self.albumsList.count {
			// the order must be reversed
			if(self.albumsList[i].tracks == nil) {
				continue;
			}
			
			self.albumsList[i].allTracks = self.albumsList[i].allTracks!.reversed();
			// take the first 6 tracks from the list
			self.albumsList[i].tracks = Array(self.albumsList[i].allTracks!.prefix(6));
		}
		self.collectionView.reloadData();
		self.collectionView.layoutIfNeeded();
	}
	
}

extension AllTracksListViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.albumsList[indexPath.item];
		
		if(item.tracks!.count > 1) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TracksForAlbumCollectionViewCell.ID, for: indexPath) as! TracksForAlbumCollectionViewCell;
			cell.navigationDelegate = self;
			
			cell.albumTitleView.text = item.title;
			cell.albumArtistView.text = item.artist?.name;
			if(item.image != nil) {
				cell.albumImageView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: item.image!), placeholder: UIImage(named: "artwork"));
			} else {
				cell.albumImageView.image = UIImage(named: "artwork");
			}
			
			cell.dataList = item.tracks!;
			cell.fullList = item.allTracks!;
			
			return cell;
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackInTracksListViewCell.ID, for: indexPath) as! TrackInTracksListViewCell;
			let track = item.tracks!.first!;
			
			cell.titleView.text = track.title;
			cell.artistAndAlbumTitleView.text = track.album?.artist?.name;
			
			if(item.title != nil && !item.title!.lowercased().hasSuffix("single")) {
				cell.artistAndAlbumTitleView.text = cell.artistAndAlbumTitleView.text! + " - " + item.title!;
			}
			if(track.image != nil) {
				cell.albumImageView.kf.setImage(with: URL.createFrom(localOrRemoteAddress: track.image!), placeholder: UIImage(named: "artwork"));
			} else {
				cell.albumImageView.image = UIImage(named: "artwork");
			}
			
			return cell;
		}
	}
	
}

extension AllTracksListViewController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.albumsList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let singleAlbum = self.albumsList[indexPath.item];
		
		if(singleAlbum.tracks!.count <= 1) {
			self.playableList.removeAll();
			for item in singleAlbum.tracks! {
				let playableItem = PlayableItem(url: URL(string: item.fileName!)!);
				playableItem._id = item.id;
				playableItem.title = item.title;
				playableItem.artist = item.album?.artist?.name;
				playableItem.artistObj = item.album?.artist;
				playableItem.album = item.album?.title;
				playableItem.albumObj = item.album;
				playableItem.imageUrl = item.image;
				playableItem.colors = item.colors;
				
				self.playableList.append(playableItem);
			}
			self.sendPlayBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: 0);
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let item = self.albumsList[indexPath.item];
		
		if(item.tracks!.count > 1) {
			let innerContainerHeight = CGFloat(item.tracks!.count) * 50.0 + TracksForAlbumCollectionViewCell.insetSize * (CGFloat(item.tracks!.count) + 1.0)
			
			let height = self.device.isPad ? CGFloat(170 + 80) : CGFloat(150 + 30);
			return CGSize(width: self.collectionView.frame.width - (self.device.isPad ? 50 : 0), height: innerContainerHeight + height);
		} else {
			let height = self.device.isPad ? CGFloat(170 + 80) : CGFloat(110 + 30);
			return CGSize(width: self.collectionView.frame.width - (self.device.isPad ? 50 : 0), height: height);
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// getting the scroll offset
		let bottomEdge: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height;
		if bottomEdge >= scrollView.contentSize.height {
			// we are at the bottom
			if(!self.isLoading && self.canLoadMore) {
				if(self.tracksList.last != nil && self.tracksList.last?.id != nil) {
					self.loadTracks(lastId: self.tracksList.last!.id!);
				}
			}
		}
	}
	
}
