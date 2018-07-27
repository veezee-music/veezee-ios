//
//  AlbumTrackViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 4/14/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

enum AlbumsTracksListPageType {
	case album
	case playlist
}

class AllAlbumsPlaylistsListViewController: _BasePageViewController {
	
	var albumsList = [Album]();
	var playableList = [PlayableItem]();
	
	let insetSize: CGFloat = 15;
	
	lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = self.insetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = self.insetSize;
		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: self.insetSize, left: self.insetSize, bottom: self.insetSize, right: self.insetSize);
		
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
		collectionView.register(MusicSmallViewCell.self, forCellWithReuseIdentifier: MusicSmallViewCell.ID);
		collectionView.register(TracksForAlbumCollectionViewCell.self, forCellWithReuseIdentifier: TracksForAlbumCollectionViewCell.ID);
		collectionView.register(SpacerCollectionViewCell.self, forCellWithReuseIdentifier: SpacerCollectionViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}();
	
	var isLoading = false;
	var canLoadMore = true;
	
	var cardSize: CGSize = .zero;
	
	convenience init() {
		self.init(type: nil);
	}
	
	init(type: AlbumsTracksListPageType?) {
		super.init(nibName: nil, bundle: nil);
		
		if(type != nil) {
			if(type! == .album) {
				self.title = "Albums";
				self.loadAlbums();
			} else if(type! == .playlist) {
				self.title = "Playlists";
				self.loadPlaylists();
			}
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		
		if(self.device.isPad) {
			let width = (self.view.frame.width / 4) - 20;
			self.cardSize = CGSize(width: width, height: width + 50);
		} else {
			let width = (self.view.frame.width / 2) - 25;
			self.cardSize = CGSize(width: width, height: width + 50);
		}
		
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
	
	func loadAlbums(lastId: String = "0") {
		self.isLoading = true;
		if(lastId == "0") {
			HUD.showProgress();
		}
		API.Lists.albums(lastId: lastId) { (albums, errorMessage) in
			self.isLoading = false;
			HUD.hide(animated: true);
			if(albums != nil && albums!.count > 0) {
				for n in albums! {
					self.albumsList.append(n);
				}
//				var emptyAlbumToBeDetectedAndUsedAsSpacer = Album();
//				emptyAlbumToBeDetectedAndUsedAsSpacer.title = SpacerCollectionViewCell.ID;
//				self.albumsList.append(emptyAlbumToBeDetectedAndUsedAsSpacer);
				
				self.collectionView.reloadData();
			} else {
				self.canLoadMore = false;
			}
		}
	}
	
	func loadPlaylists(lastId: String = "0") {
		self.isLoading = true;
		if(lastId == "0") {
			HUD.showProgress();
		}
		API.Lists.playlists(lastId: lastId) { (playlists, errorMessage) in
			self.isLoading = false;
			HUD.hide(animated: true);
			if(playlists != nil && playlists!.count > 0) {
				for n in playlists! {
					self.albumsList.append(n);
				}
				var emptyAlbumToBeDetectedAndUsedAsSpacer = Album();
				emptyAlbumToBeDetectedAndUsedAsSpacer.title = SpacerCollectionViewCell.ID;
				self.albumsList.append(emptyAlbumToBeDetectedAndUsedAsSpacer);
				
				self.collectionView.reloadData();
			} else {
				self.canLoadMore = false;
			}
		}
	}
	
}


extension AllAlbumsPlaylistsListViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.albumsList[indexPath.item];
		
		if(item.title == SpacerCollectionViewCell.ID) {
			// spacer cell
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpacerCollectionViewCell.ID, for: indexPath) as! SpacerCollectionViewCell;
			
			return cell;
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicSmallViewCell.ID, for: indexPath) as! MusicSmallViewCell;
			
			if(item.image != nil && item.image != "") {
				cell.artworkImageView.kf.setImage(with: URL(string: item.image!), placeholder: UIImage(named: "artwork"));
			} else {
				cell.artworkImageView.image = UIImage(named: "artwork");
			}
			
			cell.titleView.text = item.title;
			if(item.artist != nil) {
				cell.artistView.text = item.artist?.name;
			} else {
				
			}
			
			return cell;
		}
	}
	
}

extension AllAlbumsPlaylistsListViewController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.albumsList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = self.albumsList[indexPath.item];
		
		self.navigateToVCFor(album: item);
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let item = self.albumsList[indexPath.item];
		
		if(item.title == SpacerCollectionViewCell.ID) {
			// spacer, width doesn't matter
			return CGSize(width: view.bounds.width / 2, height: BottomPlayer.Height);
		} else {
			return self.cardSize;
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// getting the scroll offset
		let bottomEdge: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height;
		if bottomEdge >= scrollView.contentSize.height {
			// we are at the bottom
			if(!self.isLoading && self.canLoadMore) {
				if(self.albumsList.last != nil && self.albumsList.last?.id != nil) {
					self.loadAlbums(lastId: self.albumsList.last!.id!);
				}
			}
		}
	}
	
}
