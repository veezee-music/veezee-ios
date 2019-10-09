//
//  AlbumViewController.swift
//  bxpi
//
//  Created by Vahid Amiri Motlagh on 2/14/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import Foundation
import DeviceKit
import PKHUD

fileprivate extension Selector {
	static let vc = AlbumViewController.self;
	static let playButtonPressed = #selector(vc.playButtonPressed);
	static let shuffleButtonPressed = #selector(vc.shuffleButtomPressed);
}

class AlbumViewController: _BasePageViewController {
	
	lazy var tabBarHeight = self.tabBarController?.tabBar.frame.size.height;
	
	var album: Album?;
	var albumHasImportedTracks: Bool = false;
	var playableList = [PlayableItem]();
	var currentSelectedPlayableItem : Int = 0;
	var tracksListViews = [UIView]();
	
	lazy var viewContainer : UIScrollView = {
		let viewContainer = UIScrollView();
		// the height will ofcourse be adjusted after we calculate the actual needed space
		viewContainer.contentSize = CGSize(width: self.view.bounds.width, height: 0);
		viewContainer.isScrollEnabled = true;
		
		return viewContainer;
	}();
	
	lazy var headerView: UIView = {
		let headerView = UIView()
		
		return headerView;
	}();
	
	lazy var albumArtView: UIImageView = {
		let iv = UIImageView(frame: .zero);
		if(Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR) {
			iv.borderWidth = 0.3;
			iv.borderColor = Constants.IMAGES_BORDER_COLOR;
		}
		iv.contentMode = .scaleAspectFit;
		iv.clipsToBounds = true;
		iv.layer.cornerRadius = 4;
		
		let bannerImage = UIImage(named: "artwork")!;
		iv.image = bannerImage;
		
		return iv;
	}();
	
	lazy var titleView: UILabel = {
		let title = UILabel();
		title.textColor = Constants.PRIMARY_TEXT_COLOR;
		let boldFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize);
		title.font = boldFont.withSize(30);
		// we want the text to wrap to next line
		title.lineBreakMode = .byWordWrapping;
		title.numberOfLines = 0;
		
		
		return title;
	}();
	
	lazy var artistView: UILabel = {
		let artist = UILabel();
		artist.font = artist.font.withSize(22);
		artist.textColor = Constants.SECONDARY_TEXT_COLOR;
		// we want the text to wrap to next line
		artist.lineBreakMode = .byWordWrapping;
		artist.numberOfLines = 0;
		
		return artist;
	}();
	
	lazy var playButtonView: LightButtonWithBackground = {
		let playButton = LightButtonWithBackground();
		playButton.setIcon(prefixText: "", prefixTextColor: .red, icon: .ionicons(.play), iconColor: Constants.PRIMARY_TEXT_COLOR, postfixText: "   Play", postfixTextColor: Constants.PRIMARY_TEXT_COLOR, forState: .normal, textSize: 18, iconSize: 18);
		playButton.borderColor = Constants.PRIMARY_TEXT_COLOR;
		playButton.borderWidth = 1.0;
		playButton.layer.cornerRadius = 4;
		playButton.clipsToBounds = true;
		playButton.addTarget(self, action: .playButtonPressed, for: .touchUpInside);
		
		return playButton;
	}();
	
	lazy var shuffleButtonView: LightButtonWithBackground = {
		let shuffleButton = LightButtonWithBackground();
		shuffleButton.setIcon(prefixText: "", prefixTextColor: .red, icon: .ionicons(.shuffle), iconColor: Constants.PRIMARY_TEXT_COLOR, postfixText: "   Shuffle", postfixTextColor: Constants.PRIMARY_TEXT_COLOR, forState: .normal, textSize: 18, iconSize: 18);
		shuffleButton.borderColor = Constants.PRIMARY_TEXT_COLOR;
		shuffleButton.borderWidth = 1.0;
		shuffleButton.layer.cornerRadius = 4;
		shuffleButton.clipsToBounds = true;
		shuffleButton.addTarget(self, action: .shuffleButtonPressed, for: .touchUpInside);
		
		return shuffleButton;
	}();
	
	lazy var titlesAndListContainer: UIView = {
		let titlesAndListContainer = UIView();
		
		return titlesAndListContainer;
	}();
	
	lazy var tracksContainer: UIView = {
		let tracksContainer = UIView();
		
		return tracksContainer;
	}();
	
	let spacerSize: CGFloat = 20;
	let buttonsHeight: CGFloat = 40;
	lazy var artworkHeight: CGFloat = {
		return (self.view.bounds.width / 2) - 30;
	}();
	
	var tracksListHeight : CGFloat = 0;
	
	convenience init() {
		self.init(album: nil);
	}
	
	init(album: Album?) {
		super.init(nibName: nil, bundle: nil);
		
		if(album != nil) {
			self.album = album;
			//
			if(self.album!.tracks == nil || self.album!.tracks!.count <= 0) {
				self.loadAlbum(_id: album!.id!);
			}
			//
			DispatchQueue.main.async {
				self.titleView.text = album?.title;
				self.artistView.text = album?.artist?.name;
				if(album?.image != nil) {
					self.albumArtView.kf.setImage(with: URL(string: (album?.image)!), placeholder: UIImage(named: "artwork"));
				}
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
		super.viewDidLoad();
		
		// This is necessary to prevent bugs when pushing this VC from the SearchViewController that uses large titles
		self.navigationController?.navigationBar.prefersLargeTitles = false;
		
		self.view.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.view.addSubview(self.viewContainer);
		self.viewContainer.snp.makeConstraints ({(make) -> Void in
			make.height.equalTo(self.view.bounds.height)
			make.width.equalTo(self.view.bounds.width)
			make.left.right.equalTo(0)
		});
		
		self.viewContainer.addSubview(self.headerView);
		self.headerView.snp.makeConstraints ({(make) -> Void in
			make.height.equalTo(spacerSize)
			make.width.equalToSuperview()
		});
		
		if(self.device.isPhone || self.device.isPod) {

			self.artworkHeight = (self.view.bounds.width / 2) - 30;
			
			let artworkContainer = UIView();
			self.viewContainer.addSubview(artworkContainer);
			artworkContainer.snp.makeConstraints ({(make) -> Void in
				make.left.equalTo(spacerSize)
				make.width.height.equalTo(artworkHeight)
				make.top.equalTo(headerView.snp.bottom)
			});
			
			artworkContainer.addSubview(self.albumArtView);
			self.albumArtView.snp.makeConstraints ({(make) -> Void in
				make.left.right.top.bottom.equalTo(0)
			});
			
			self.viewContainer.addSubview(titleView);
			let boldFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize);
			self.titleView.font = boldFont.withSize(18);
			self.titleView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(headerView.snp.bottom)
				make.left.equalTo(artworkContainer.snp.right).offset(spacerSize)
				make.width.equalTo(self.view.bounds.width / 2 - 20)
				make.height.lessThanOrEqualTo(50)
			});
			self.titleView.layoutIfNeeded();
			
			self.viewContainer.addSubview(self.artistView);
			self.artistView.font = self.artistView.font.withSize(15);
			self.artistView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(self.titleView.snp.bottom).offset(5);
				make.left.equalTo(artworkContainer.snp.right).offset(spacerSize)
				make.width.equalTo(self.view.bounds.width / 2 - 20)
				make.height.lessThanOrEqualTo(40)
			});
			self.artistView.layoutIfNeeded();
			
			self.viewContainer.addSubview(self.playButtonView);
			self.playButtonView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(self.albumArtView.snp.bottom).offset(spacerSize)
				make.left.equalTo(spacerSize)
				make.width.equalTo((self.view.bounds.width / 2) - 30)
				make.height.equalTo(buttonsHeight)
			});
			
			self.viewContainer.addSubview(self.shuffleButtonView);
			self.shuffleButtonView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(self.albumArtView.snp.bottom).offset(spacerSize)
				make.left.equalTo(self.playButtonView.snp.right).offset(spacerSize)
				make.width.equalTo((self.view.bounds.width / 2) - 30)
				make.height.equalTo(buttonsHeight)
			});
			
			self.viewContainer.addSubview(tracksContainer);
			self.tracksContainer.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(self.playButtonView.snp.bottom).offset(spacerSize);
				make.width.equalToSuperview()
				make.height.equalTo(self.view.bounds.height);
			});
		} else {
			
			self.artworkHeight = (self.view.bounds.width / 2) - 20 * 3;
			
			let artworkContainer = UIView();
			self.viewContainer.addSubview(artworkContainer);
			artworkContainer.snp.makeConstraints ({(make) -> Void in
				make.left.equalTo(spacerSize)
				make.width.height.equalTo(artworkHeight)
				make.top.equalTo(headerView.snp.bottom)
			});
			
			let trackCountView = UILabel();
			if(self.album != nil && self.album?.tracks != nil) {
				let type = self.album?.artist != nil ? "Album" : "Playlist";
				trackCountView.text = String(describing: self.album!.tracks!.count) + " Songs, \(type)";
			}
			trackCountView.textColor = Constants.SECONDARY_TEXT_COLOR;
			trackCountView.font = trackCountView.font.withSize(18);
			self.viewContainer.addSubview(trackCountView);
			trackCountView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(artworkContainer.snp.bottom).offset(15)
				make.height.equalTo(30)
				make.left.equalTo(spacerSize)
				make.width.equalTo((self.view.bounds.width / 2) - 20 * 3)
			});
			
			let halfWidth = self.view.bounds.width / 2;
			
			self.viewContainer.addSubview(self.playButtonView);
			self.playButtonView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(trackCountView.snp.bottom).offset(15)
				make.left.equalTo(35)
				make.width.equalTo((halfWidth - 20 * 3) / 2 - 30)
				make.height.equalTo(buttonsHeight)
			});
			
			self.viewContainer.addSubview(self.shuffleButtonView);
			self.shuffleButtonView.snp.makeConstraints ({(make) -> Void in
				make.top.equalTo(trackCountView.snp.bottom).offset(15)
				make.left.equalTo(self.playButtonView.snp.right).offset(30)
				make.width.equalTo((halfWidth - 20 * 3) / 2 - 30)
				make.height.equalTo(buttonsHeight)
			});
			
			artworkContainer.addSubview(self.albumArtView);
			self.albumArtView.snp.makeConstraints ({(make) -> Void in
				make.left.right.top.bottom.equalTo(0)
			});
			
			self.viewContainer.addSubview(self.titleView);
			self.titleView.snp.makeConstraints ({(make) -> Void in
				make.left.equalTo(artworkContainer.snp.right).offset(40)
				make.width.equalTo(self.view.bounds.width / 2 - 20)
				make.top.equalTo(headerView.snp.bottom)
				make.height.lessThanOrEqualTo(100);
			});
			self.titleView.layoutIfNeeded();

			self.viewContainer.addSubview(self.artistView);
			self.artistView.snp.makeConstraints ({(make) -> Void in
				make.left.equalTo(artworkContainer.snp.right).offset(40)
				make.width.equalTo(self.view.bounds.width / 2 - 20)
				make.top.equalTo(self.titleView.snp.bottom).offset(10);
				make.height.lessThanOrEqualTo(60);
			});
			self.artistView.layoutIfNeeded();
			
			self.viewContainer.addSubview(self.tracksContainer);
			self.tracksContainer.snp.makeConstraints ({(make) -> Void in
				make.left.equalTo(artworkContainer.snp.right).offset(40)
				make.top.equalTo(self.artistView.snp.bottom).offset(100)
				make.width.equalTo(self.view.bounds.width - ((self.view.bounds.width / 2) - 20 * 3) - /*60*/80)
			});
		}
		
		self.generatePlayableList();
		
		self.initializeBottomPlayer();
    }
	
	func generatePlayableList() {
		if(album?.tracks != nil) {
			DispatchQueue.global(qos: .background).async {
				// build the PlayableList, used by audio player
				
//								var _album: Album?;
//								do {
//									let encodedData = try JSONEncoder().encode(self.album);
//									_album = try JSONDecoder().decode(Album.self, from: encodedData);
//									// Unarchive into a new instance
//									_album?.tracks = nil;
//								} catch {}
				
				for item in self.album!.tracks! {
					let playableItem = PlayableItem(url: URL(string: item.fileName!)!);
					playableItem._id = item.id;
					playableItem.title = item.title;
					playableItem.artist = item.album?.artist?.name;
					playableItem.artistObj = item.album?.artist;
					if(self.album != nil) {
						playableItem.album = self.album!.title;
						playableItem.albumObj = self.album;
					}
					playableItem.imageUrl = item.image;
					playableItem.colors = item.colors;
					
					if(item.album == nil) {
						// normal album item
						playableItem.artist = self.album?.artist?.name;
						playableItem.imageUrl = self.album?.image;
					} else {
						// imported album track
						self.albumHasImportedTracks = true;
						if(self.album?.artist == nil && item.image == nil) {
							// playlist item and doesn't have artwork
							// use the one provided by playlist
							playableItem.imageUrl = self.album?.image;
						}
					}
					
					self.playableList.append(playableItem);
				}
				
				if let r = generatePlayableListFromAlbum(list: self.album!.tracks!, parentAlbum: self.album) {
					self.playableList = r.list;
					self.albumHasImportedTracks = r.hasImportedTracks;
				} else {
					return;
				}
				
				DispatchQueue.main.async {
					// run on the main queue after the previous codes
					if(self.device.isPhone) {
						self.layoutTracksListForPhone();
					} else {
						self.layoutTracksListForPad();
					}
				}
			}
		}
	}
	
	func loadAlbum(_id: String) {
		HUD.showProgress();
		API.Get.album(_id: _id) { (album, errorMessage) in
			HUD.hide(animated: true);
			if(album == nil) {
				return;
			}
			
			self.album = album;
			self.generatePlayableList();
		}
	}
	
	var trackLongPressEnded = false;
	
	func layoutTracksListForPhone() {
		for (index, playableItem) in self.playableList.enumerated() {
			let item = TrackItemView();
			item.itemId = index;
			
			item.isUserInteractionEnabled = true;
			let tap = UITapGestureRecognizer(target: self, action: #selector(self.sendPlayBroadcastNotification(_:)));
			item.addGestureRecognizer(tap);
			
			self.tracksContainer.addSubview(item);
			
			let itemHeight : CGFloat = 53;
			
			if(index == 0) {
				item.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(0).offset(10)
					make.left.right.equalTo(0)
					make.height.greaterThanOrEqualTo(itemHeight)
				});
			} else {
				item.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(tracksContainer.subviews[tracksContainer.subviews.count - 2].snp.bottom).offset(10)
					make.left.right.equalTo(0)
					make.height.greaterThanOrEqualTo(itemHeight)
				});
			}
			
			let topBorder: CALayer = CALayer();
			topBorder.frame = CGRect(x: 50.0, y: 0.0, width: self.view.bounds.width - 50, height: 0.5);
			topBorder.backgroundColor = UIColor.lightGray.cgColor;
			item.layer.addSublayer(topBorder);
			
			let indexView = UILabel();
			indexView.textColor = .lightGray;
			indexView.text = String(index + 1); // just for display purposes we need to start counting at 1
			item.addSubview(indexView);
			indexView.snp.makeConstraints ({(make) -> Void in
				make.top.bottom.equalTo(0).offset(5);
				make.left.equalTo(20);
			});
			
			let titleView = UILabel();
			titleView.numberOfLines = 0;
			titleView.textColor = Constants.PRIMARY_TEXT_COLOR;
			titleView.text = playableItem.title;
			titleView.font = titleView.font.withSize(16);
			
			let artistView = UILabel();
			artistView.textColor = Constants.SECONDARY_TEXT_COLOR;
			artistView.text = playableItem.artist;
			artistView.font = artistView.font.withSize(13);
			
			var views = [titleView];
			
			if(self.albumHasImportedTracks) {
				views.append(artistView);
			}
			
			let titlesStackView = UIStackView(arrangedSubviews: views);
			titlesStackView.axis = .vertical;
			//titlesStackView.alignment = .center;
			titlesStackView.distribution = .fillProportionally;
			item.addSubview(titlesStackView);
			
			titlesStackView.snp.makeConstraints ({(make) -> Void in
				make.top.bottom.equalTo(0).offset(5);
				make.left.equalTo(indexView.snp.left).offset(30);
				make.right.equalTo(10)
			});
			
			tracksListHeight += itemHeight + 10;
			
			let cellLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.cellLongPressed(_:)));
			cellLongPressGestureRecognizer.minimumPressDuration = 0.5;
			cellLongPressGestureRecognizer.delaysTouchesBegan = true;
			item.addGestureRecognizer(cellLongPressGestureRecognizer);
		}
		
		var heightToAdd : CGFloat = 0;
		if(tracksListHeight > self.view.bounds.width - spacerSize) {
			heightToAdd = self.spacerSize + (BottomPlayer.Height * 2) + self.artworkHeight + self.buttonsHeight + self.spacerSize * 2;
		}
		
		// for some reason we have to set the contentSize on the main thread
		// https://stackoverflow.com/questions/39560586/ios-10-issue-uiscrollview-not-scrolling-even-when-contentsize-is-set
		DispatchQueue.main.async {
			self.viewContainer.contentSize.height += (self.tracksListHeight + heightToAdd + 120);
		}
	}
	
	func layoutTracksListForPad() {
		for (index, playableItem) in self.playableList.enumerated() {
			let item = TrackItemView();
			item.itemId = index;

			item.isUserInteractionEnabled = true;
			let tap = UITapGestureRecognizer(target: self, action: #selector(self.sendPlayBroadcastNotification));
			item.addGestureRecognizer(tap);

			self.tracksContainer.addSubview(item);
			
			let itemHeight : CGFloat = 58;

			if(index == 0) {
				item.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(0)
					make.left.right.equalTo(0)
					make.height.greaterThanOrEqualTo(itemHeight)
				});
			} else {
				item.snp.makeConstraints({(make) -> Void in
					make.top.equalTo(tracksContainer.subviews[self.tracksContainer.subviews.count - 2].snp.bottom).offset(10)
					make.left.right.equalTo(0)
					make.height.greaterThanOrEqualTo(itemHeight)
				});
			}

			let topBorder: CALayer = CALayer();
			topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width - ((self.view.bounds.width / 2) - 20 * 3) - 60, height: 0.5);
			topBorder.backgroundColor = UIColor.lightGray.cgColor;
			item.layer.addSublayer(topBorder);

			let indexView = UILabel();
			indexView.textColor = .lightGray;
			indexView.text = String(index + 1); // just for display purposes we need to start counting at 1
			item.addSubview(indexView);
			indexView.snp.makeConstraints ({(make) -> Void in
				make.top.bottom.equalTo(0).offset(5);
				make.left.equalTo(0);
			});

			let titleView = UILabel();
			titleView.numberOfLines = 0;
			titleView.textColor = Constants.PRIMARY_TEXT_COLOR;
			titleView.text = playableItem.title;
			titleView.font = titleView.font.withSize(18);
			
			let artistView = UILabel();
			artistView.textColor = Constants.SECONDARY_TEXT_COLOR;
			artistView.text = playableItem.artist;
			artistView.font = artistView.font.withSize(14);
			
			var views = [titleView];
			
			if(self.albumHasImportedTracks) {
				views.append(artistView);
			}
			
			let titlesStackView = UIStackView(arrangedSubviews: views);
			titlesStackView.axis = .vertical;
//			titlesStackView.alignment = .center;
			titlesStackView.distribution = .fillProportionally;
			item.addSubview(titlesStackView);
			
			titlesStackView.snp.makeConstraints ({(make) -> Void in
				make.top.bottom.equalTo(0).offset(5);
				make.left.equalTo(indexView.snp.left).offset(40);
				make.right.equalTo(10)
			});

			tracksListHeight += itemHeight + 10;
			tracksListViews.append(item);

			let cellLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.cellLongPressed(_:)));
			cellLongPressGestureRecognizer.minimumPressDuration = 0.5;
			cellLongPressGestureRecognizer.delaysTouchesBegan = true;
			item.addGestureRecognizer(cellLongPressGestureRecognizer);
		}

		var heightToAdd : CGFloat = 0;
		if(tracksListHeight > self.view.bounds.width - self.spacerSize) {
			heightToAdd = self.spacerSize + BottomPlayer.Height + 30 + 30 + 50 + 10;
		}

		// for some reason we have to set the contentSize on the main thread
		// https://stackoverflow.com/questions/39560586/ios-10-issue-uiscrollview-not-scrolling-even-when-contentsize-is-set
		DispatchQueue.main.async {
			self.viewContainer.contentSize.height += (self.tracksListHeight + heightToAdd + self.titleView.frame.height + self.artistView.frame.height + 120);
			
			self.tracksContainer.snp.makeConstraints ({(make) -> Void in
				make.height.equalTo(self.viewContainer.contentSize.height)
			});
		}
	}

	@objc
	func cellLongPressed(_ sender: UILongPressGestureRecognizer) {
		if (sender.state == UIGestureRecognizer.State.ended) {
			self.trackLongPressEnded = false;
			return;
		}

		if(self.trackLongPressEnded) {
			return;
		}

//		if var track: Track = self.album?.tracks?[index] {
//			var _album: Album?;
//			do {
//				let encodedData = try JSONEncoder().encode(self.album);
//				_album = try JSONDecoder().decode(Album.self, from: encodedData);
//				// Unarchive into a new instance
//				_album?.tracks = nil;
//				track.album = _album;
//				NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.trackLongPressedBroadcastNotificationKey), object: self, userInfo: ["track" : track]);
//			} catch {}
//		}

		self.trackLongPressEnded = true;
	}
	
	@objc
	func playButtonPressed() {
		self.sendPlayListBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: 0, mode: .normal);
	}
	
	@objc
	func shuffleButtomPressed() {
		self.sendPlayListBroadcastNotification(playableList: self.playableList, currentPlayableItemIndex: 0, mode: .shuffle);
	}
	
	func sendPlayListBroadcastNotification(playableList: [PlayableItem], currentPlayableItemIndex: Int, mode: AudioPlayerMode) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : playableList, "currentPlayableItemIndex": currentPlayableItemIndex, "mode": mode]);
	}
	
	@objc
	func sendPlayBroadcastNotification(_ sender : UITapGestureRecognizer) {
		let view = sender.view as! TrackItemView;
		NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.audioPlayerInitiatePlayBroadcastNotificationKey), object: self, userInfo: ["playableList" : self.playableList, "currentPlayableItemIndex": view.itemId!]);
	}
	
	override func getTitle() -> String? {
		return "";
	}
}


class TrackItemView : UIView {
	var itemId : Int?;
}
