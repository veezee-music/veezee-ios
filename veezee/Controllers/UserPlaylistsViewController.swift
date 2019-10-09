//
//  ModalViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 5/13/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import UIKit
import AnimatedTextInput
import PMAlertController
import PKHUD
import RxSwift
import RxCocoa

class UserPlaylistsViewController: _BaseCommonViewController {
	
	var isLoading = BehaviorRelay<Bool>(value: false);
	let disposeBag = DisposeBag();
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		get {
			return .lightContent;
		}
	}
	
//	override var preferredContentSize: CGSize {
//		get {
//			return CGSize.init(width: self.view.frame.size.width, height: self.view.frame.size.height)
//		}
//		set {
//			super.preferredContentSize = newValue
//			
//		}
//	}
	
	init() {
		super.init(nibName: nil, bundle: nil);
	}
	
	init(trackToAddToPlaylist track: Track) {
		super.init(nibName: nil, bundle: nil);
		
		self.selectedTrack = track;
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	lazy var titleView: UILabel = {
		let title = UILabel();
		title.text = "Choose/Create a playlist";
		title.font = UIFont.systemFont(ofSize: self.device.isPad ? 30 : 20, weight: .heavy);
		title.textColor = Constants.WHITE_THEME.PRIMARY_TEXT_COLOR;
		
		return title;
	}();
	
	lazy var createButtonView: UIButton = {
		let button = IconedButton();
		button.initButton(icon: .ionicons(.iosPlusOutline), iconSize: 40, color: .black, forState: .normal);
		button.setIcon(color: UIColor.black.withAlphaComponent(0.5), forState: .highlighted);
		button.addTarget(self, action: #selector(self.createButtonClicked), for: .touchUpInside);
		
		return button;
	}();
	
	lazy var confirmButtonView: UIButton = {
		let button = IconedButton();
		button.setTitle("Cancel", for: .normal);
		button.setTitleColor(.red, for: .normal);
		button.setTitleColor(UIColor.red.withAlphaComponent(0.5), for: .highlighted);
		button.addTarget(self, action: #selector(self.confirmCancelButtonClicked), for: .touchUpInside);
		
		return button;
	}();
	
	weak var delegate: UserPlaylistsDelegate?;
	
	//
	
	let insetSize: CGFloat = 20;
	
	var playlistsList = [Album]();
	
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
		collectionView.backgroundColor = .white;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.isPagingEnabled = false;
		collectionView.decelerationRate = UIScrollView.DecelerationRate.normal;
		collectionView.register(UserPlaylistViewCell.self, forCellWithReuseIdentifier: UserPlaylistViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}();
	
	let nameInputTag = 395543232;
	
	var createNewPlaylistFormContainer = UIView();
	var createNewPlaylistFormSubmitButton = LGButton();
	
	var cardSize: CGSize = .zero;
	
	var selectedPlaylist: Album?;
	var selectedPlaylistCell: UserPlaylistViewCell?;
	var selectedTrack: Track?;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .white;
		
		self.setupLoadingObserver();
		
		self.view.addSubview(self.titleView);
		self.titleView.snp.makeConstraints ({ (make) in
			make.left.equalTo(20)
			make.top.equalTo(20)
		});
		
		self.view.addSubview(self.confirmButtonView);
		self.confirmButtonView.snp.makeConstraints ({ (make) in
			make.right.equalTo(0).inset(20)
			make.top.equalTo(10)
		});
		
//		self.view.addSubview(self.createButtonView);
//		self.createButtonView.snp.makeConstraints ({ (make) in
//			make.right.equalTo(0).inset(20)
//			make.top.equalTo(10)
//		});
		
		if(self.device.isPad) {
			let width = (self.view.frame.width / 3) - 30;
			self.cardSize = CGSize(width: width, height: width + 50);
		} else {
			let width = (self.view.frame.width / 2) - 30;
			self.cardSize = CGSize(width: width, height: width + 50);
		}
		
		self.view.addSubview(self.collectionView);
		self.collectionView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(self.titleView.snp.bottom).offset(20)
			make.bottom.equalTo(0)
			make.left.right.equalTo(0)
		});
		
		self.loadPlaylists();
		self.layoutCreatePlaylistForm();
	}
	
	@objc
	func createButtonClicked() {
		
	}
	
	@objc
	func confirmCancelButtonClicked() {
		if(self.confirmButtonView.titleLabel?.text == "Confirm" && self.selectedPlaylist != nil) {
			self.addTrackToPlaylist(track: self.selectedTrack!, playlist: self.selectedPlaylist!);
		} else {
			self.dismiss(animated: true, completion: nil);
		}
	}
	
	func loadPlaylists(lastId: String = "0") {
		self.isLoading.accept(true);
		
		API.Account.Playlists.get() { (playlists, errorMessage) in
			self.isLoading.accept(false);
			
			self.playlistsList.removeAll();
			let lastItem = Album();
			self.playlistsList.append(lastItem);
			if(playlists != nil && playlists!.count > 0) {
				for n in playlists! {
					self.playlistsList.append(n);
				}
			}
			self.collectionView.reloadData();
		}
	}
	
	func addTrackToPlaylist(track: Track, playlist: Album) {
		self.isLoading.accept(true);
		
		API.Account.Playlists.Tracks.add(track: track, playlist: playlist) { (errorMessage) in
			self.isLoading.accept(false);
			
			HUD.flash(.success, delay: 0.25) { finished in
				self.dismiss(animated: true, completion: {
					self.delegate?.trackAddedToPlaylist(playlist: self.selectedPlaylist!);
				});
			}
		}
	}
	
	func sendBackPlaylist(_ playlist: Album) {
		self.delegate?.playlistSelected(playlist: playlist);
	}
}

extension UserPlaylistsViewController {
	private func setupLoadingObserver() {
		self.isLoading.asObservable()
			.subscribe(onNext: { loading in
				
				loading ? HUD.showProgress() : HUD.hide(animated: true);
				
			})
			.disposed(by: self.disposeBag);
	}
}

extension UserPlaylistsViewController {
	
	@objc
	func createNewPlaylistViewCellClicked() {
		UIView.animate(withDuration: 0.5) {
			self.clearAllCellsFromCheckMarks();
			self.resetCellSelectionState();
			self.createNewPlaylistFormContainer.alpha = 1.0;
			self.view.bringSubviewToFront(self.createNewPlaylistFormContainer);
		}
	}
	
	@objc
	func createNewPlaylistFormCancelClicked() {
		UIView.animate(withDuration: 0.5) {
			self.createNewPlaylistFormContainer.alpha = 0.0;
			self.view.sendSubviewToBack(self.createNewPlaylistFormContainer);
		}
	}
	
	func submitNewPlaylist(title: String) {
		self.createNewPlaylistFormSubmitButton.isLoading = true;

		API.Account.Playlists.new(title: title) { (playlist, errorMessage) in
			self.createNewPlaylistFormSubmitButton.isLoading = false;
			if(playlist != nil && errorMessage == nil) {
				// success
				
				self.createNewPlaylistFormCancelClicked();
				self.loadPlaylists();
//				self.dismiss(animated: true, completion: {
//					self.sendBackPlaylist(playlist!);
//				});
			} else {
				let errorAC = PMAlertController(title: "Error", description: errorMessage!, image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
			}
		}
	}
	
	@objc
	func createNewPlaylistFormSubmitButtonClicked() {
		let nameInput = self.createNewPlaylistFormContainer.viewWithTag(nameInputTag) as! AnimatedTextInput;
		
		if(nameInput.text == nil || nameInput.text!.count <= 0) {
			return;
		}
		
		self.submitNewPlaylist(title: nameInput.text!);
	}
	
	func layoutCreatePlaylistForm() {
		let containerViewWidth = self.device.isPad ? ((self.view.frame.width / 1.5) + (20 * 2)) : self.view.frame.width - 50;
		
		createNewPlaylistFormContainer.layer.zPosition = 10;
		createNewPlaylistFormContainer.cornerRadius = 4;
		createNewPlaylistFormContainer.clipsToBounds = true;
		createNewPlaylistFormContainer.backgroundColor = Constants.BLACK_THEME.PRIMARY_COLOR;
		createNewPlaylistFormContainer.alpha = 0;
		self.view.addSubview(createNewPlaylistFormContainer);
		createNewPlaylistFormContainer.snp.makeConstraints({(make) -> Void in
			make.width.equalTo(containerViewWidth);
			make.centerX.centerY.equalTo(self.view)
		});
		createNewPlaylistFormContainer.layoutIfNeeded();
		
		var childViewsFullHeight: CGFloat = 0;
		
		let titleView = UILabel();
		titleView.text = "Create a new playlist";
		titleView.textColor = .white;
		let boldFont = UIFont.boldSystemFont(ofSize:UIFont.labelFontSize);
		titleView.font = boldFont.withSize(25);
		
		createNewPlaylistFormContainer.addSubview(titleView);
		titleView.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(30)
			make.centerX.equalTo(self.view)
		});
		titleView.layoutIfNeeded();
		childViewsFullHeight += titleView.bounds.height + 30;
		
		let nameInput = AnimatedTextInput();
		nameInput.tag = nameInputTag;
		nameInput.style = CustomAnimatedTextInputStyle();
		nameInput.type = .email;
		nameInput.placeHolderText = "New playlist name";
		
		createNewPlaylistFormContainer.addSubview(nameInput);
		nameInput.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(titleView.snp.bottom)
			make.left.right.equalTo(0)
		});
		nameInput.layoutIfNeeded();
		childViewsFullHeight += nameInput.bounds.height;
		
		createNewPlaylistFormSubmitButton.titleString = "Submit";
		createNewPlaylistFormSubmitButton.titleFontSize = 18;
		createNewPlaylistFormSubmitButton.titleColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		createNewPlaylistFormSubmitButton.cornersRadius = 4;
		createNewPlaylistFormSubmitButton.bgColor = Constants.ACCENT_COLOR;
		createNewPlaylistFormSubmitButton.shadowRadius = 4;
		createNewPlaylistFormSubmitButton.shadowOpacity = 2;
		createNewPlaylistFormSubmitButton.shadowOffset = CGSize(width: 0, height: 1);
		createNewPlaylistFormSubmitButton.shadowColor = Constants.ACCENT_COLOR;
		createNewPlaylistFormSubmitButton.addTarget(self, action: #selector(UserPlaylistsViewController.createNewPlaylistFormSubmitButtonClicked), for: .touchUpInside);
		createNewPlaylistFormSubmitButton.loadingColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		createNewPlaylistFormSubmitButton.loadingString = "Please wait...";
		createNewPlaylistFormSubmitButton.loadingSpinnerColor = Constants.BLACK_THEME.PRIMARY_TEXT_COLOR;
		
		createNewPlaylistFormContainer.addSubview(createNewPlaylistFormSubmitButton);
		createNewPlaylistFormSubmitButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(nameInput.snp.bottom).offset(30)
			make.left.right.equalTo(0).offset(20).inset(20)
		});
		createNewPlaylistFormSubmitButton.layoutIfNeeded();
		childViewsFullHeight += (createNewPlaylistFormSubmitButton.bounds.height + 30);
		
		let cancelButton = UIButton();
		cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14);
		cancelButton.setTitle("Cancel", for: .normal);
		cancelButton.setTitleColor(UIColor.lightGray, for: .normal);
		cancelButton.setTitleColor(UIColor.gray, for: .highlighted);
		
		createNewPlaylistFormContainer.addSubview(cancelButton);
		cancelButton.snp.makeConstraints({(make) -> Void in
			make.top.equalTo(createNewPlaylistFormSubmitButton.snp.bottom).offset(30 / 2)
			make.left.right.equalTo(0)
		});
		cancelButton.addTarget(self, action: #selector(UserPlaylistsViewController.createNewPlaylistFormCancelClicked), for: .touchUpInside);
		cancelButton.layoutIfNeeded();
		childViewsFullHeight += (cancelButton.bounds.height + 30);
		
		createNewPlaylistFormContainer.snp.makeConstraints({(make) -> Void in
			make.centerX.centerY.equalTo(self.view)
			make.width.equalTo(containerViewWidth)
			make.height.equalTo(childViewsFullHeight)
		});
	}
	
	func playlistSelected(playlist: Album, cell: UserPlaylistViewCell) {
		UIView.animate(withDuration: 0.25) {
			self.clearAllCellsFromCheckMarks();
			
			if(self.selectedPlaylist?.id != playlist.id) {
				cell.checkIconView.alpha = 1.0;
				self.confirmButtonView.setTitle("Confirm", for: .normal);
				self.selectedPlaylist = playlist;
				self.selectedPlaylistCell = cell;
			} else {
				self.resetCellSelectionState();
			}
		}
	}
	
	func clearAllCellsFromCheckMarks() {
		for view in self.collectionView.visibleCells as! [UserPlaylistViewCell] {
			view.checkIconView.alpha = 0;
		}
	}
	
	func resetCellSelectionState() {
		self.confirmButtonView.setTitle("Cancel", for: .normal);
		self.selectedPlaylist = nil;
		self.selectedPlaylistCell = nil;
	}
	
}

extension UserPlaylistsViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserPlaylistViewCell.ID, for: indexPath) as! UserPlaylistViewCell;
		
		let item = self.playlistsList[indexPath.item];
		
		if(indexPath.item == 0) {
			cell.artworkImageView.image = UIImage(named: "plus-accent");
			cell.titleView.text = "Create a new playlist";
			cell.titleView.textColor = Constants.ACCENT_COLOR;
			cell.titleView.textAlignment = .center;
			cell.noteView.text = "";
			
		} else {
			cell.titleView.text = item.title;
			if(item.tracks != nil) {
				cell.noteView.text = "\(item.tracks!.count) tracks"
			}
			cell.artworkImageView.image = UIImage(named: "artwork");
			cell.titleView.textColor = Constants.WHITE_THEME.PRIMARY_TEXT_COLOR;
			cell.titleView.textAlignment = .left;
			
			if(self.selectedPlaylist?.id == item.id) {
				cell.checkIconView.alpha = 1.0;
			} else {
				cell.checkIconView.alpha = 0;
			}
		}
		
		return cell;
	}
	
}

extension UserPlaylistsViewController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.playlistsList.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = self.playlistsList[indexPath.item];
		let cell = collectionView.cellForItem(at: indexPath) as! UserPlaylistViewCell;

		if(indexPath.item == 0) {
			self.createNewPlaylistViewCellClicked();
		} else {
			self.playlistSelected(playlist: item, cell: cell);
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return self.cardSize;
	}
	
//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		// getting the scroll offset
//		let bottomEdge: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height;
//		if bottomEdge >= scrollView.contentSize.height {
//			// we are at the bottom
//			if(!self.isLoading && self.canLoadMore) {
//				if(self.albumsList.last != nil && self.albumsList.last?.id != nil) {
////					self.loadAlbums(lastId: self.albumsList.last!.id!);
//				}
//			}
//		}
//	}
	
}
