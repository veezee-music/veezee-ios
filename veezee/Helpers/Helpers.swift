//
//  Commons.swift
//  UNIVER30t-Native
//
//  Created by Vahid Amiri Motlagh on 01/26/18.
//  Copyright © 2018 UNIVER30t Network. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit
import MediaPlayer
import PMAlertController
import CouchbaseLiteSwift

struct DeviceCategories {
	static let iphones5_5inch: [Device] = [.iPhone6Plus, .iPhone7Plus, .iPhone8Plus, .simulator(.iPhone6Plus), .simulator(.iPhone7Plus), .simulator(.iPhone8Plus)];
	static let iphones5_8inch: [Device] = [.iPhoneX, .simulator(.iPhoneX)];
	static let ipads9_7inch: [Device] = [.iPad5, .iPadAir, .iPadAir2, .iPadPro9Inch, .simulator(.iPad5), .simulator(.iPadAir), .simulator(.iPadAir2), .simulator(.iPadPro9Inch)];
	static let ipads10_5inch: [Device] = [.iPadPro10Inch, .simulator(.iPadPro10Inch)];
	static let ipads12_9inch: [Device] = [.iPadPro12Inch, .iPadPro12Inch2, .simulator(.iPadPro12Inch), .simulator(.iPadPro12Inch2)];
}

func extractAuthorizationToken(token: String) -> String {
	return String(token.dropFirst(7));
}

func generateCacheTrackName(playableItem: PlayableItem, includeExtension: Bool = false) -> String {
	let fileNameWithoutExtension = "\(playableItem.artist ?? "") - \(playableItem.title ?? "") - \(playableItem.album ?? "")";
	if(includeExtension) {
		return "\(fileNameWithoutExtension).\(playableItem.url!.pathExtension)";
	} else {
		return fileNameWithoutExtension;
	}
}

func generateRandomString(length: Int) -> String {
	let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	let allowedCharsCount = UInt32(allowedChars.count)
	var randomString = ""
	
	for _ in 0..<length {
		let randomNum = Int(arc4random_uniform(allowedCharsCount))
		let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
		let newCharacter = allowedChars[randomIndex]
		randomString += String(newCharacter)
	}
	
	return randomString
}

func statusBarHeight() -> CGFloat {
	let statusBarSize = UIApplication.shared.statusBarFrame.size;
	return min(statusBarSize.width, statusBarSize.height);
}

func isDeviceLandscape() -> Bool {
	if(UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight) {
		return true;
	}
	
	return false;
}

func isDevicePortrait() -> Bool {
	if(UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown) {
		return true;
	}
	
	return false;
}

func format(duration: TimeInterval) -> String {
	let formatter = DateComponentsFormatter()
	formatter.zeroFormattingBehavior = .pad
	
	if duration >= 3600 {
		formatter.allowedUnits = [.hour, .minute, .second];
	} else {
		formatter.allowedUnits = [.minute, .second];
	}
	
	return formatter.string(from: duration) ?? "";
}

func deleteFileInDirectory(subDirectory: String, fileName: String) -> Void {
	let fileManager = FileManager.default;
	if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
	{
		// create a folder for our downloads if it doesn't already exist
		let filePath = documentsDirectoryPath.appending("/\(subDirectory)").appending("/\(fileName)");
		if (fileManager.fileExists(atPath: filePath)) {
			do {
				try fileManager.removeItem(atPath: filePath);
			} catch  {
				print("error removing contents of directory");
			}
		}
	}
}

func deleteAllFilesInDirectory(subDirectory: String = "") -> Void {
	let fileManager = FileManager.default;
	if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
	{
		// create a folder for our downloads if it doesn't already exist
		let dir = documentsDirectoryPath.appending("/\(subDirectory)");
		if (fileManager.fileExists(atPath: dir)) {
			do {
				let filePaths = try fileManager.contentsOfDirectory(atPath: dir);
				for filePath in filePaths {
					try fileManager.removeItem(atPath: dir + "/" + filePath);
				}
			} catch  {
				print("error removing contents of directory");
			}
		}
	}
}

func pixel(toPoints px: CGFloat) -> CGFloat {
	let pointsPerInch: CGFloat = 72.0;
	let scale: CGFloat = 1;
	var pixelPerInch: CGFloat;
	// aka dpi
	if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
		pixelPerInch = CGFloat((132 * scale));
	} else if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
		pixelPerInch = CGFloat((163 * scale));
	} else {
		pixelPerInch = CGFloat((160 * scale));
	}
	
	let result: CGFloat = px * pointsPerInch / pixelPerInch;
	return result;
}

extension Bundle {
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String;
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String;
	}
}

extension UIDevice {
	var iPhoneX: Bool {
		return UIScreen.main.nativeBounds.height == 2436
	}
}

extension UIView {
	func addSubviewOnce(_ view: UIView?) {
		if(view == nil) {
			return;
		}
		if(!view!.isDescendant(of: self)) {
			self.addSubview(view!);
		}
	}
}

extension UIView {
	@IBInspectable public var cornerRadius: CGFloat {
		get { return self.layer.cornerRadius }
		set { self.layer.cornerRadius = newValue }
	}
	
	@IBInspectable public var borderWidth: CGFloat {
		get { return self.layer.borderWidth }
		set { self.layer.borderWidth = newValue }
	}
	
	@IBInspectable public var borderColor: UIColor {
		get { return UIColor(cgColor: self.layer.borderColor!) }
		set { self.layer.borderColor = newValue.cgColor }
	}
}

extension NSLayoutConstraint {
	@IBInspectable var preciseConstant: Int {
		get {
			return Int(constant * UIScreen.main.scale)
		}
		set {
			constant = CGFloat(newValue) / UIScreen.main.scale
		}
	}
}

extension UIImageView
{
	func roundCornersForAspectFit(radius: CGFloat)
	{
		if let image = self.image {
			
			//calculate drawingRect
			let boundsScale = self.bounds.size.width / self.bounds.size.height
			let imageScale = image.size.width / image.size.height
			
			var drawingRect: CGRect = self.bounds
			
			if boundsScale > imageScale {
				drawingRect.size.width =  drawingRect.size.height * imageScale
				drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
			} else {
				drawingRect.size.height = drawingRect.size.width / imageScale
				drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
			}
			let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
			let mask = CAShapeLayer()
			mask.path = path.cgPath
			self.layer.mask = mask
		}
	}
}

extension UIColor{
	convenience init(hex: String, alpha: CGFloat = 1.0) {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		self.init(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(alpha)
		)
	}
}

extension UICollectionView {
	func scrollToNearestVisibleCollectionViewCell() {
		self.decelerationRate = UIScrollView.DecelerationRate.fast
		let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
		var closestCellIndex = -1
		var closestDistance: Float = .greatestFiniteMagnitude
		for i in 0..<self.visibleCells.count {
			let cell = self.visibleCells[i]
			let cellWidth = cell.bounds.size.width
			let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
			
			// Now calculate closest cell
			let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
			if distance < closestDistance {
				closestDistance = distance
				closestCellIndex = self.indexPath(for: cell)!.row
			}
		}
		if closestCellIndex != -1 {
			self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
		}
	}
}

class ProgressSlider: UISlider {
	@IBInspectable var trackHeight: CGFloat = 5;
	
	override func trackRect(forBounds: CGRect) -> CGRect {
		return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight));
	}
	
//	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//		return true;
//	}
}

extension MPVolumeView {
	var volumeSlider : UISlider {
		self.showsRouteButton = false;
		self.showsVolumeSlider = false;
		self.isHidden = true;
		var slider = UISlider();
		for subview in self.subviews {
			if subview.isKind(of: UISlider.self) {
				slider = subview as! UISlider;
				slider.isContinuous = false;
				(subview as! UISlider).value = AVAudioSession.sharedInstance().outputVolume;
				return slider;
			}
		}
		return slider;
	}
}

extension UIView {
	var allSubViews : [UIView] {
		
		var array = [self.subviews].flatMap {$0}
		
		array.forEach { array.append(contentsOf: $0.allSubViews) }
		
		return array
	}
}

extension UIViewController {
	func configureChildViewController(childController: UIViewController, onView: UIView?) {
		var holderView = self.view
		if let onView = onView {
			holderView = onView
		}
		addChild(childController)
		holderView?.addSubview(childController.view)
		constrainViewEqual(holderView: holderView!, view: childController.view)
		childController.didMove(toParent: self)
		childController.willMove(toParent: self)
	}
	
	func constrainViewEqual(holderView: UIView, view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		//pin 100 points from the top of the super
		let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
										toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
		let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
										   toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
		let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
										 toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
		let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
										  toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
		
		holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
	}
}

extension UIView
{
	func copyView<T: UIView>() -> T {
		return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
	}
}

extension UIAlertController {
	func show() {
		let win = UIWindow(frame: UIScreen.main.bounds)
		let vc = UIViewController()
		vc.view.backgroundColor = .clear
		win.rootViewController = vc
		win.windowLevel = UIWindow.Level.alert + 1
		win.makeKeyAndVisible()
		vc.present(self, animated: true, completion: nil)
	}
}

public extension PMAlertController {
	func show() {
		let win = UIWindow(frame: UIScreen.main.bounds)
		let vc = UIViewController()
		vc.view.backgroundColor = .clear
		win.rootViewController = vc
		win.windowLevel = UIWindow.Level.alert + 1
		win.makeKeyAndVisible()
		vc.present(self, animated: true, completion: nil)
	}
}

extension UIView {
	func snapshot() -> UIImage {
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
		drawHierarchy(in: bounds, afterScreenUpdates: true)
		let result = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return result!
	}
}

extension UIWindow {
	func replaceRootViewControllerWith(_ replacementController: UIViewController, animated: Bool, completion: (() -> Void)?) {
		let snapshotImageView = UIImageView(image: self.snapshot())
		self.addSubview(snapshotImageView)
		
		let dismissCompletion = { () -> Void in // dismiss all modal view controllers
			self.rootViewController = replacementController
			self.bringSubviewToFront(snapshotImageView)
			if animated {
				UIView.animate(withDuration: 0.4, animations: { () -> Void in
					snapshotImageView.alpha = 0
				}, completion: { (success) -> Void in
					snapshotImageView.removeFromSuperview()
					completion?()
				})
			}
			else {
				snapshotImageView.removeFromSuperview()
				completion?()
			}
		}
//		if self.rootViewController!.presentedViewController != nil {
//			self.rootViewController!.dismiss(animated: false, completion: dismissCompletion)
//		}
//		else {
			dismissCompletion()
//		}
	}
}

extension Encodable {
	var dictionary: [String: Any]? {
		guard let data = try? JSONEncoder().encode(self) else { return nil }
		return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
	}
}

extension Date {
	func toDateTimeString() -> String {
		let formatter = DateFormatter();
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
		
		let myString = formatter.string(from: self);
		
		return myString;
	}
}

extension String {
	func toDate() -> Date? {
		let formatter = DateFormatter();
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
		
		let yourDate = formatter.date(from: self);
		
		return yourDate;
	}
}

func getDateTimeForHoursInTheFuture(hours: Int) -> Date {
	var components = DateComponents();
	components.setValue(hours, for: .hour);
	let date: Date = Date();
	let expirationDate = Calendar.current.date(byAdding: components, to: date);
	
	return expirationDate!;
}

func getDateTimeForMinutesInTheFuture(minutes: Int) -> Date {
	var components = DateComponents();
	components.setValue(minutes, for: .minute);
	let date: Date = Date();
	let expirationDate = Calendar.current.date(byAdding: components, to: date);
	
	return expirationDate!;
}

func getDateTimeForNow() -> Date {
	return Date();
}

extension URL {
	static func createFrom(localOrRemoteAddress: String) -> URL {
		if(localOrRemoteAddress.starts(with: "http")) {
			return URL(string: localOrRemoteAddress)!;
		} else {
			return URL(fileURLWithPath: localOrRemoteAddress)
		}
	}
}

extension UIColor {
	func toHexString(includeAlpha: Bool = true) -> String  {
		var r: CGFloat = 0;
		var g: CGFloat = 0;
		var b: CGFloat = 0;
		var a: CGFloat = 0;
		self.getRed(&r, green: &g, blue: &b, alpha: &a);
		
		guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
			return String("");
		}
		
		if (includeAlpha) {
			return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
		} else {
			return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
		}
	}
}

extension UIColor {
	
	static func contrastRatio(between color1: UIColor, and color2: UIColor) -> CGFloat {
		// https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
		
		let luminance1: CGFloat = color1.luminance();
		let luminance2: CGFloat = color2.luminance();
		
		let luminanceDarker = min(luminance1, luminance2);
		let luminanceLighter = max(luminance1, luminance2);
		
		return (luminanceLighter + 0.05) / (luminanceDarker + 0.05);
	}
	
	func contrastRatio(with color: UIColor) -> CGFloat {
		return UIColor.contrastRatio(between: self, and: color);
	}
	
	func luminance() -> CGFloat {
		// https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
		
		let ciColor = CIColor(color: self);
		
		func adjust(colorComponent: CGFloat) -> CGFloat {
			return (colorComponent < 0.03928) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4);
		}
		
		return 0.2126 * adjust(colorComponent: ciColor.red) + 0.7152 * adjust(colorComponent: ciColor.green) + 0.0722 * adjust(colorComponent: ciColor.blue);
	}
}

func getOfflineTrackURLSavedInDatabase(id: String) -> URL? {
	let offlineDocument: Document? = OfflineAccessDatabase.sharedInstance.database?.document(withID: id);
	if(offlineDocument != nil) {
		let offlinePlayableItem: PlayableItem? = try! JSONDecoder().decode(PlayableItem?.self, from: try! JSONSerialization.data(withJSONObject: offlineDocument?.toDictionary(), options: []));
		let fileName = offlinePlayableItem?._id;
		let fileExtension = offlinePlayableItem?.url?.pathExtension;
		let filePath = Constants.MUSIC_TRACKS_CACHE_FOLDER_PATH.appending("/\(fileName!).\(fileExtension!)");
		
		let cacheUrl = URL(fileURLWithPath: filePath);
		
		let fileManager = FileManager.default;
		if(!fileManager.fileExists(atPath: cacheUrl.path)) {
			// file doesn't exist in the cache directory
			print("file doesn't exist")
			return nil;
		}
		
		return cacheUrl;
	}
	
	// no offline entry exists
	return nil;
}

func generatePlayableListFromTracksList(list: [Track]) -> [PlayableItem] {
	var playableList: [PlayableItem] = [PlayableItem]();
	
	for item in list {
		let playableItem = PlayableItem(url: URL(string: item.fileName!)!);
		playableItem._id = item.id;
		playableItem.title = item.title;
		playableItem.artist = item.album?.artist?.name;
		playableItem.artistObj = item.album?.artist;
		playableItem.album = item.album?.title;
		playableItem.albumObj = item.album;
		playableItem.colors = item.colors;
		playableItem.imageUrl = item.image;
		//KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL.createFrom(localOrRemoteAddress: item.image!)), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) -> () in
		//playableItem.artworkImage = image;
		//};
		
		//
		if let cacheUrl = getOfflineTrackURLSavedInDatabase(id: playableItem._id!) {
			playableItem.url = cacheUrl;
			playableItem.isOffline = true;
		}
		
		playableList.append(playableItem);
	}
	
	return playableList;
}

func generatePlayableListFromAlbum(list: [Track], parentAlbum: Album?) -> (list: [PlayableItem], hasImportedTracks: Bool)? {
	var playableList: [PlayableItem] = [PlayableItem]();
	var hasImportedTracks = false;
	
	for item in list {
		let playableItem = PlayableItem(url: URL(string: item.fileName!)!);
		playableItem._id = item.id;
		playableItem.title = item.title;
		playableItem.artist = item.album?.artist?.name;
		playableItem.artistObj = item.album?.artist;
		if(parentAlbum != nil) {
			playableItem.album = parentAlbum!.title;
			playableItem.albumObj = parentAlbum;
		}
		playableItem.colors = item.colors;
		playableItem.imageUrl = item.image;
		
		if let cacheUrl = getOfflineTrackURLSavedInDatabase(id: playableItem._id!) {
			playableItem.url = cacheUrl;
			playableItem.isOffline = true;
		}
		
		if(item.album == nil) {
			// normal album item
			playableItem.artist = parentAlbum?.artist?.name;
			playableItem.imageUrl = parentAlbum?.image;
		} else {
			// imported album track
			hasImportedTracks = true;
			if(parentAlbum?.artist == nil && item.image == nil) {
				// playlist item and doesn't have artwork
				// use the one provided by playlist
				playableItem.imageUrl = parentAlbum?.image;
			}
		}
		
		playableList.append(playableItem);
	}
	
	return (playableList, hasImportedTracks);
}

extension UIPanGestureRecognizer {
	
	func isUp(view: UIView) -> Bool? {
		let detectionLimit: CGFloat = 50
		let velocityy : CGPoint = velocity(in: view)
		if velocityy.y > detectionLimit {
			// Gesture went down
			return false;
		} else if velocityy.y < -detectionLimit {
			// Gesture went up
			return true;
		}
		
		return nil;
	}
	
	func isLeft(view: UIView) -> Bool? {
		let detectionLimit: CGFloat = 50
		let velocityy : CGPoint = velocity(in: view)
		if velocityy.x > detectionLimit {
			// Gesture went right
			return false;
		} else if velocityy.x < -detectionLimit {
			// Gesture went left
			return true;
		}
		
		return nil;
	}
}

extension UIStackView {
	
	func removeAllArrangedSubviews() {
		
		let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
			self.removeArrangedSubview(subview)
			return allSubviews + [subview]
		}
		
		// Deactivate all constraints
		NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
		
		// Remove the views from self
		removedSubviews.forEach({ $0.removeFromSuperview() })
	}
}
