//
//  ContentViewController.swift
//  UNIVER30t-Native
//
//  Created by Vahid Amiri Motlagh on 1/27/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import UIKit
import PKHUD
import DeviceKit
import PMAlertController
import RxCocoa
import RxSwift

struct SearchQueryList {
	var title: String?;
	var queries = [String]();
}

class SearchViewController: _BasePageViewController {
	
	var searchQueryLists = [SearchQueryList]() {
		didSet {
			self.setupUI();
		}
	}
	
	private var _searchPageItems = [HomePageItem]();
	var searchPageItems: [HomePageItem] {
		set {
			var newCollection = [HomePageItem]();
			var albumsEmpty = false, tracksEmpty = false;
			for n in newValue {
				if(n.type == HomePageItemType.Album && (n.albumList == nil || n.albumList!.count <= 0)) {
					albumsEmpty = true;
					continue;
				}
				if(n.type == HomePageItemType.Track && (n.trackList == nil || n.trackList!.count <= 0)) {
					tracksEmpty = true;
					continue;
				}
				var spacer = HomePageItem();
				spacer.type = HomePageItemType.Spacer;
				newCollection.append(spacer);
				
				newCollection.append(n);
			}
			if(albumsEmpty && tracksEmpty) {
				self.showEmptyResultViews();
				return;
			}
			if(newValue.count > 0) {
				// two more spacer just to make it look better
				var spacer = HomePageItem();
				spacer.type = HomePageItemType.Spacer;
				newCollection.append(spacer);
				
				var spacer2 = HomePageItem();
				spacer2.type = HomePageItemType.Spacer;
				newCollection.append(spacer2);
			}
			
			_searchPageItems = newCollection;
			self.showResultsViews();
			self.collectionView.reloadData();
		}
		get { return _searchPageItems }
	}
	
	let resultsView = UIView();
	lazy var collectionView = self.getCollectionView();
	let initialView = UIView();
	let emptyResultView = UIView();
	
	lazy var pageActivityView: PKHUD = {
		let progressView = PKHUD(viewToPresentOn: self.view);
		progressView.contentView = PKHUDRotatingImageView(image: UIImage(named: "progress"));
		
		return progressView;
	}();
	
	var searchResultMarginFromSides: CGFloat = 0.0;
	
	lazy var navigationBarHeight = navigationController?.navigationBar.frame.size.height;
	
	var searchController: UISearchController!;
	
	let disposeBag = DisposeBag();
	var searchQuery = BehaviorRelay<String?>(value: nil);
	var isLoading = BehaviorRelay<Bool>(value: false);
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.setupObservers();
		
		self.view.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.searchController = UISearchController(searchResultsController: nil);
		self.navigationController?.navigationBar.prefersLargeTitles = true;
		self.searchController.searchResultsUpdater = self;
		self.searchController.dimsBackgroundDuringPresentation = false;
		self.searchController.searchBar.delegate = self;
		self.navigationItem.searchController = self.searchController;
		self.searchController.searchBar.sizeToFit();
		self.navigationItem.hidesSearchBarWhenScrolling = false;
		self.searchController.searchBar.placeholder = "veezee";
		
		// not working
//		if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//			textfield.textColor = Constants.PRIMARY_TEXT_COLOR;
//			textfield.backgroundColor = UIColor.lightGray;
//		}
		if(Constants.PRIMARY_COLOR != Constants.WHITE_THEME.PRIMARY_COLOR) {
			// dark theme
			searchController.searchBar.barStyle = UIBarStyle.black;
		}
		
		definesPresentationContext = true;
		
		self.loadInitialSearchQueries();
		self.setupUI();
		
		self.initializeBottomPlayer();
	}
	
	func loadInitialSearchQueries() {
		API.Lists.latestSearchTrends (handler: { (trends, errorMessage) in
			
			var recentsList = SearchQueryList(title: "Recent", queries: []);
			recentsList.queries.append("future")
			recentsList.queries.append("50 cent")
			recentsList.queries.append("local result 3")
			recentsList.queries.append("local result 4")
			recentsList.queries.append("local result 5")
			recentsList.queries.append("local result 6")
			recentsList.queries.append("local result 7")
			recentsList.queries.append("local result 8")
			recentsList.queries.append("local result 9")
			recentsList.queries.append("local result 10")
			
			var trendsList = SearchQueryList(title: "Trending", queries: []);
			for n in trends {
				trendsList.queries.append(n);
			}
			
			self.searchQueryLists.append(contentsOf: [recentsList, trendsList]);
		});
	}
	
	func loadSearchPageResult(q: String) {
		self.isLoading.accept(true);
		
		API.Lists.search(q: q, handler: { (list, errorMessage) in
			self.isLoading.accept(false);
			
			if(list == nil && errorMessage == nil) {
				let errorAC = PMAlertController(title: "Error", description: errorMessage!, image: nil, style: .alert);
				errorAC.alertTitle.textColor = Constants.ACCENT_COLOR;
				errorAC.addAction(PMAlertAction(title: "Dismiss", style: .cancel, action: nil));
				errorAC.show();
				return;
			}
			
			if(list != nil) {
				self.searchPageItems = list!;
			}
			
		});
	}
	
	override func getTitle() -> String? {
		return "Search";
	}
	
	func showInitialViews() {
		self.resultsView.isHidden = true;
		self.initialView.isHidden = false;
		self.emptyResultView.isHidden = true;
	}
	
	func showResultsViews() {
		self.resultsView.isHidden = false;
		self.initialView.isHidden = true;
		self.emptyResultView.isHidden = true;
	}
	
	func showEmptyResultViews() {
		self.resultsView.isHidden = true;
		self.initialView.isHidden = true;
		self.emptyResultView.isHidden = false;
	}
	
	func setupObservers() {
		self.setupSearchQueryObserver();
		self.setupLoadingObserver();
	}
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
	
	func updateSearchResults(for searchController: UISearchController) {
		guard let q = searchController.searchBar.text else {
			return;
		}
		
		self.searchQuery.accept(q);
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let q = searchBar.text else {
			return;
		}
		
		if(q.count < 3) {
			let warning = UIAlertController(title: "Error", message: "Please enter 3 characters or more.", preferredStyle: .alert);
			let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default);
			warning.addAction(okAction);
			present(warning, animated: true, completion: nil);
			return;
		}
		
		self.loadSearchPageResult(q: q);
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.searchQuery.accept("");
	}
	
}

extension SearchViewController {
	
	func setupSearchQueryObserver() {
		self.searchQuery.observeOn(MainScheduler.instance)
			.subscribeOn(MainScheduler.instance)
			.asObservable()
			.subscribe(onNext: { searchQuery in
				
				if(searchQuery == "") {
					self.showInitialViews();
				}
				
				if(searchQuery == nil) {
					return;
				}
				
			})
			.disposed(by: self.disposeBag);
	}
	
	func setupLoadingObserver() {
		self.isLoading.asObservable()
			.subscribe(onNext: { loading in
				
				loading ? HUD.showProgress() : HUD.hide(animated: true);
				
			})
			.disposed(by: self.disposeBag);
	}
	
}

extension SearchViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = self.searchPageItems[indexPath.item];
		
		if(item.type == HomePageItemType.Album && item.albumList != nil && item.albumList!.count > 0) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchRowAlbumsCollectionViewCell.ID, for: indexPath) as! SearchRowAlbumsCollectionViewCell;
			cell.navigationDelegate = self;
			cell.dataList = item.albumList!;
			cell.collectionViewTitleView.text = item.title ?? ""//?.capitalized;
			return cell;
		} else if(item.type == HomePageItemType.Track && item.trackList != nil && item.trackList!.count > 0) {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchRowTracksCollectionViewCell.ID, for: indexPath) as! SearchRowTracksCollectionViewCell;
			cell.dataList = item.trackList!;
			cell.collectionViewTitleView.text = item.title ?? ""//?.capitalized;
			return cell;
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpacerCollectionViewCell.ID, for: indexPath) as! SpacerCollectionViewCell;
		return cell;
	}
	
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.searchPageItems.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let item = self.searchPageItems[indexPath.item];
		
		var numberOfItems: CGFloat = 0;
		if(item.type == HomePageItemType.Album && item.albumList != nil) {
			numberOfItems = CGFloat(item.albumList!.count);
		} else if(item.type == HomePageItemType.Track && item.trackList != nil) {
			numberOfItems = CGFloat(item.trackList!.count);
		}
		
		if(item.type == HomePageItemType.Album || item.type == HomePageItemType.Track) {
			let lineSpacing = numberOfItems > 1 ? ((numberOfItems - 1) * 15) : 0;
			let insetSpacing: CGFloat = 15 * 2;
			return CGSize(width: self.collectionView.bounds.width, height: (numberOfItems * 80) + lineSpacing + insetSpacing + 45 + 1);
		}
		
		// spacer collectionview
		return CGSize(width: self.collectionView.bounds.width, height: 10);
	}
}

extension SearchViewController: SearchQueryListDelegate {
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator);
		
		coordinator.animate(alongsideTransition: nil, completion: { _ in
			self.collectionView.removeFromSuperview();
			self.collectionView = self.getCollectionView();
			self.initialView.removeFromSuperview();
			self.setupUI();
			self.initializeBottomPlayer();
		});
		
	}
	
	func querySelected(query: String) {
		self.searchController.searchBar.text = query;
		self.loadSearchPageResult(q: query);
	}
	
	func setupUI() {
		self.showInitialViews();
		
		if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact) {
			self.searchResultMarginFromSides = 30;
		} else {
			self.searchResultMarginFromSides = 100;
		}
		
		// empty result view
		let noResultsLabel = UILabel();
		noResultsLabel.text = "No results";
		noResultsLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.heavy);
		noResultsLabel.textColor = Constants.PRIMARY_TEXT_COLOR;
		self.emptyResultView.addSubviewOnce(noResultsLabel);
		noResultsLabel.snp.remakeConstraints ({ (make) in
			make.center.equalToSuperview()
		});
		self.view.addSubviewOnce(self.emptyResultView);
		self.emptyResultView.snp.remakeConstraints ({ (make) in
			make.edges.equalTo(0)
		});
		self.emptyResultView.layoutIfNeeded();
		
		// results view
		self.view.addSubviewOnce(self.resultsView);
		self.resultsView.snp.remakeConstraints ({ (make) in
			make.edges.equalTo(0)
		});
		self.resultsView.layoutIfNeeded();
		
		self.resultsView.addSubviewOnce(self.collectionView);
		self.collectionView.snp.makeConstraints({ (make) -> Void in
			make.centerX.equalToSuperview()
			make.width.equalTo(self.view.bounds.width - self.searchResultMarginFromSides)
			make.top.equalTo(0);
			make.bottom.equalTo(0)
		});
		self.collectionView.collectionViewLayout.invalidateLayout();
		
		// initial view
		self.view.addSubviewOnce(self.initialView);
		self.initialView.snp.remakeConstraints ({ (make) in
			make.edges.equalTo(0)
		});
		self.initialView.layoutIfNeeded();
		
		// narrow width on the screen, so show the one column view
		if(self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact) {
			self.setupInitialViewsInOneColumn();
		} else {
			self.setupInitialViewsInTwoColumns();
		}
	}
	
	func setupInitialViewsInOneColumn() {
		let recentsCollectionView = SearchSignleItemCollectionViewContainer(frame: CGRect.zero);
		recentsCollectionView.delegate = self;
		self.initialView.addSubviewOnce(recentsCollectionView);
		recentsCollectionView.snp.remakeConstraints ({ (make) in
			make.left.right.equalTo(0).offset(30).inset(30)
			make.top.bottom.equalTo(0)
		});
		recentsCollectionView.layoutIfNeeded();
		recentsCollectionView.setData(dataList: self.searchQueryLists);
	}
	
	func setupInitialViewsInTwoColumns() {
		let recentsCollectionView = SearchSignleItemCollectionViewContainer(frame: CGRect.zero);
		recentsCollectionView.delegate = self;
		self.initialView.addSubviewOnce(recentsCollectionView);
		recentsCollectionView.snp.remakeConstraints ({ (make) in
			make.left.equalTo(0).offset(30)
			make.top.bottom.equalTo(0)
			make.width.equalTo((self.view.frame.width / 2) - 60)
		});
		recentsCollectionView.layoutIfNeeded();
		if(self.searchQueryLists.indices.contains(1)) {
			recentsCollectionView.setData(dataList: [self.searchQueryLists[0]]);
		}
		
		let trendingCollectionView = SearchSignleItemCollectionViewContainer(frame: CGRect.zero);
		trendingCollectionView.delegate = self;
		self.initialView.addSubviewOnce(trendingCollectionView);
		trendingCollectionView.snp.remakeConstraints ({ (make) in
			make.right.equalTo(0).inset(30)
			make.top.bottom.equalTo(0)
			make.left.equalTo(recentsCollectionView.snp.right).offset(60)
		});
		trendingCollectionView.layoutIfNeeded();
		if(self.searchQueryLists.indices.contains(1)) {
			trendingCollectionView.setData(dataList: [self.searchQueryLists[1]]);
		}
	}
	
	func getCollectionView() -> UICollectionView {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getCollectionViewFlowLayout());
		collectionView.backgroundColor = Constants.PRIMARY_COLOR;
		collectionView.showsVerticalScrollIndicator = false;
		collectionView.showsHorizontalScrollIndicator = false;
		collectionView.isScrollEnabled = true;
		collectionView.bounces = true;
		collectionView.register(SearchRowTracksCollectionViewCell.self, forCellWithReuseIdentifier: SearchRowTracksCollectionViewCell.ID);
		collectionView.register(SearchRowAlbumsCollectionViewCell.self, forCellWithReuseIdentifier: SearchRowAlbumsCollectionViewCell.ID);
		collectionView.register(SpacerCollectionViewCell.self, forCellWithReuseIdentifier: SpacerCollectionViewCell.ID);
		collectionView.dataSource = self;
		collectionView.delegate = self;
		
		return collectionView;
	}
	
	func getCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
		let collectionViewFlowLayout = UICollectionViewFlowLayout();
		collectionViewFlowLayout.scrollDirection = .vertical;
		collectionViewFlowLayout.sectionInset = .zero;
		
		return collectionViewFlowLayout;
	}
	
}
