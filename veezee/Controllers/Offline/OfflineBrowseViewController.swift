//
//  ViewController.swift
//  UNIVER30t-Native
//
//  Created by Vahid Amiri Motlagh on 1/26/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import SnapKit
import DeviceKit
import AVFoundation
import Kingfisher
import PKHUD
import PMAlertController
import KeychainSwift
import SwiftIcons
import CouchbaseLiteSwift

class OfflineBrowseViewController: _BasePageViewController {
	lazy var navigationBarHeight = navigationController?.navigationBar.frame.size.height;
	
	let musicSmallCardInsetSize: CGFloat = 15;
	
	private var _homePageItems = [HomePageItem]();
	var homePageItems: [HomePageItem] {
		set {
			var newCollection = [HomePageItem]();
			for n in newValue {
				newCollection.append(n);
			}
			// one more spacer just to make it look better
			var spacer = HomePageItem();
			spacer.type = HomePageItemType.Spacer;
			newCollection.append(spacer);
			
			_homePageItems = newCollection;
			self.collectionView.reloadData();
		}
		get { return _homePageItems }
	}
	
	lazy var collectionView = self.getCollectionView();
	
	lazy var pageActivityView: PKHUD = {
		let progressView = PKHUD(viewToPresentOn: self.view);
		progressView.contentView = PKHUDRotatingImageView(image: UIImage(named: "progress"));
		
		return progressView;
	}();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.setupUI();
		
		self.loadHomePageLists();
		
		self.initializeBottomPlayer();
	}
	
	func loadHomePageLists() {
		var tracks = [Track]();
		var albums = [Album]();
		
		let db = OfflineAccessDatabase.sharedInstance.database!;
		let searchQuery = QueryBuilder.select(SelectResult.all()).from(DataSource.database(db));
		var items = [PlayableItem]();
		// loop through all PlayableItems in the database
		for row in try! searchQuery.execute().reversed() {
			let dict = row.toDictionary();
			let data = try! JSONSerialization.data(withJSONObject: dict["offline_access_library"]);
			let playableItem: PlayableItem = try! JSONDecoder().decode(PlayableItem.self, from: data);
			
			items.append(playableItem)
		}
		
		// build the temporary albums list made of all albums
		for playableItem in items {
			if(playableItem.albumObj == nil) {
				continue;
			}
			
			var skip = false;
			for album in albums {
				if(album.id == playableItem.albumObj?.id) {
					// duplicated album, skip
					skip = true;
					break;
				}
			}
			
			if(skip) {
				continue;
			}
			
			// add the album
			albums.append(playableItem.albumObj!);
		}
		
		// build the temporary tracks list made of all tracks
		for playableItem in items {
			var track = Track();
			track.id = playableItem._id;
			track.title = playableItem.title;
			track.album = playableItem.albumObj;
			track.image = playableItem.imageUrl;
			track.colors = playableItem.colors;
			track.fileName = Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH + "/\(playableItem.fileName!)";
			if(track.image != nil) {
				track.image = Constants.MUSIC_IMAGES_CACHE_FOLDER_PATH + "/\(playableItem.imageUrl!)";
			}
			
			tracks.append(track);
			
			for index in 0..<albums.count {
				if(albums[index].id == track.album?.id) {
					if(albums[index].tracks == nil) {
						albums[index].tracks = [Track]();
					}
					albums[index].tracks!.append(track);
				}
			}
		}
		
		var finalAlbums = [Album]();
		var finalTracks = [Track]();
		
		for album in albums {
			if(album.tracks!.count > 1) {
				// an album with more than one track, should be added to the final albums list
				finalAlbums.append(album);
			} else {
				// an album with only one track, it will be displayed as a single track
				finalTracks.append(album.tracks!.first!);
			}
		}
		
		var tracksList = HomePageItem();
		tracksList.type = HomePageItemType.Track;
		tracksList.title = "Tracks";
		tracksList.trackList = finalTracks;
		
		var albumsList = HomePageItem();
		albumsList.type = HomePageItemType.Album;
		albumsList.title = "Albums";
		albumsList.albumList = finalAlbums;
		DispatchQueue.main.async {
			var parentHomePageItem = [HomePageItem]();
			parentHomePageItem.append(tracksList)
			parentHomePageItem.append(albumsList)
			
			self.homePageItems = parentHomePageItem;
		}
		
	}
	
	@objc
	func settingsButtonPressed(_ sender: AnyObject) {
		guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
			return;
		}
		
		if UIApplication.shared.canOpenURL(settingsUrl) {
			UIApplication.shared.open(settingsUrl);
		}
	}
	
	override func addNavigationButtons() {
		let settingsBtn = UIBarButtonItem();
		settingsBtn.target = self;
		settingsBtn.action = #selector(self.settingsButtonPressed(_:));
		settingsBtn.setIcon(icon: .ionicons(.iosGear), iconSize: 30, color: Constants.PRIMARY_TEXT_COLOR);
		self.navigationItem.rightBarButtonItem = settingsBtn;
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil);
	}
}

extension OfflineBrowseViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.homePageItems[indexPath.item];
		
		if(item.type == HomePageItemType.Album) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalSmallDoubleRowCollectionViewCell.ID, for: indexPath) as! HorizontalSmallDoubleRowCollectionViewCell;
			cell.dataList = item.albumList!;
			cell.collectionViewTitleView.text = item.title ?? "";
			return cell;
		} else if(item.type == HomePageItemType.Track) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalTinyTripleRowCollectionViewCell.ID, for: indexPath) as! HorizontalTinyTripleRowCollectionViewCell;
			cell.dataList = item.trackList!;
			cell.collectionViewTitleView.text = item.title ?? "";
			return cell;
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpacerCollectionViewCell.ID, for: indexPath) as! SpacerCollectionViewCell;
		return cell;
	}
	
}

extension OfflineBrowseViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.homePageItems.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let item = self.homePageItems[indexPath.item];
		
		if(item.type == HomePageItemType.Album) {
			return CGSize(width: view.bounds.width, height: HorizontalSmallDoubleRowCollectionViewCell.cellHeight * 3 + 5 * HorizontalSmallDoubleRowCollectionViewCell.insetSize + 25);
		} else if(item.type == HomePageItemType.Track) {
			return CGSize(width: view.bounds.width, height: HorizontalTinyTripleRowCollectionViewCell.cellHeight * 4 + 6 * HorizontalTinyTripleRowCollectionViewCell.insetSize + 25);
		}
		
		// spacer collectionview
		return CGSize(width: view.bounds.width, height: BottomPlayer.Height);
	}
}

extension OfflineBrowseViewController {
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator);
		
		self.collectionView.removeFromSuperview();
		self.collectionView = self.getCollectionView();
		self.setupUI();
		self.initializeBottomPlayer();
	}
	
	func setupUI() {
		self.view.addSubviewOnce(self.collectionView);
		self.collectionView.snp.remakeConstraints({(make) -> Void in
			make.width.equalTo(self.view);
			make.height.equalTo(self.view);
			make.top.bottom.equalTo(0);
		});
		self.collectionView.collectionViewLayout.invalidateLayout();
	}
	
	func getCollectionView() -> UICollectionView {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getCollectionViewFlowLayout());
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(HorizontalSmallDoubleRowCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalSmallDoubleRowCollectionViewCell.ID);
		collectionView.register(HorizontalLargeCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalLargeCollectionViewCell.ID);
		collectionView.register(HorizontalTinyTripleRowCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalTinyTripleRowCollectionViewCell.ID);
		collectionView.register(HorizontalTinyOneRowCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalTinyOneRowCollectionViewCell.ID);
		collectionView.register(SpacerCollectionViewCell.self, forCellWithReuseIdentifier: SpacerCollectionViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}
	
	func getCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.minimumLineSpacing = self.musicSmallCardInsetSize;
		collectionViewFlowLayout.minimumInteritemSpacing = self.musicSmallCardInsetSize;
		collectionViewFlowLayout.sectionInset = .zero;
		
		return collectionViewFlowLayout;
	}
	
}
