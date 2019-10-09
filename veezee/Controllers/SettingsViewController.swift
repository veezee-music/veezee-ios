//
//  SettingsViewController.swift
//  veezee
//
//  Created by Vahid Amiri Motlagh on 9/13/18.
//  Copyright © 2018 veezee-music. All rights reserved.
//

import Foundation
import QuickTableViewController

private final class CustomSwitchCell: SwitchCell {
	override func configure(with row: Row & RowStyle) {
		super.configure(with: row);
		
		self.backgroundColor = Constants.PRIMARY_COLOR;
		self.textLabel?.textColor = Constants.PRIMARY_TEXT_COLOR;
	}
}

private final class CustomTapActionCell: TapActionCell {
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier);
		setUpAppearance();
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setUpAppearance()
	}
	
	public override func tintColorDidChange() {
		super.tintColorDidChange()
		textLabel?.textColor = tintColor
	}
	
	private func setUpAppearance() {
		textLabel?.numberOfLines = 0
		textLabel?.textAlignment = .center
		textLabel?.textColor = Constants.PRIMARY_TEXT_COLOR;
		backgroundColor = Constants.PRIMARY_COLOR;
	}
}

private final class CustomOptionRow<T: UITableViewCell>: OptionRow<T> {
	convenience init(title: String, isSelected: Bool, action: ((Row) -> Void)?, customize: Bool) {
		self.init(title: title, isSelected: isSelected, icon: nil, customization: { (cell, cellStyle) in
			cell.backgroundColor = Constants.PRIMARY_COLOR;
			cell.textLabel?.textColor = Constants.PRIMARY_TEXT_COLOR;
		}, action: action);
	}
}

class SettingsViewController: QuickTableViewController {
	
	let userDefaults = UserDefaults.standard;
	
	private lazy var offlineAccessOption: SwitchRow = SwitchRow<CustomSwitchCell>(title: "Offline Access", switchValue: Constants.OFFLINE_ACCESS, action: { _ in
		self.offlineAccessValueChanged();
	});
	
	private lazy var coloredPlayerOption: SwitchRow = SwitchRow<CustomSwitchCell>(title: "Colored Player", switchValue: Constants.COLORED_PLAYER, action: { _ in
		self.coloredPlayerValueChanged();
	});
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		SettingsBundleHelper.appSettingsBundleChanged();
		
		self.tableView.backgroundColor = Constants.PRIMARY_COLOR;
		
		self.title = "Settings";
		// add a back button to the navigation bar
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil);
		
		let themes = RadioSection(title: "THEME", options: [
			CustomOptionRow(title: "White", isSelected: Constants.PRIMARY_COLOR == Constants.WHITE_THEME.PRIMARY_COLOR, action: { _ in
				self.themeValueChanged(selectedTheme: "white");
			}, customize: true),
			CustomOptionRow(title: "Purple Dark", isSelected: Constants.PRIMARY_COLOR == Constants.PURPLE_DARK_THEME.PRIMARY_COLOR, action: { _ in
				self.themeValueChanged(selectedTheme: "purpleDark");
			}, customize: true),
			CustomOptionRow(title: "Black", isSelected: Constants.PRIMARY_COLOR == Constants.BLACK_THEME.PRIMARY_COLOR, action: { _ in
				self.themeValueChanged(selectedTheme: "black");
			}, customize: true)
			], footer: "App restart is required.");
		themes.alwaysSelectsOneOption = true;
		
		let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
		let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String;
		
		tableContents = [
			Section(title: nil, rows: [], footer: "veezee for iOS v\(version)(\(build))"),
			Section(title: nil, rows: [self.offlineAccessOption, self.coloredPlayerOption]),
			themes,
			Section(title: "OFFLINE CACHE", rows: [
				TapActionRow<CustomTapActionCell>(title: "Clear offline cache", action: { [weak self] in self?.clearCache($0) })
				])
		]
	}
	
	private func clearCache(_ sender: Row) {
		try? OfflineAccessDatabase.sharedInstance.database?.delete();
		
		let alertController = UIAlertController(title: "Clear Cache", message: "Clear the app from memory and run again for changes to take effect.", preferredStyle: UIAlertController.Style.alert);
		alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil));
		self.present(alertController, animated: true, completion: nil);
	}
	
}

extension SettingsViewController {
	func offlineAccessValueChanged() {
		self.userDefaults.set(self.offlineAccessOption.switchValue, forKey: "offline_access_preference");
		SettingsBundleHelper.appSettingsBundleChanged();
	}
	
	func coloredPlayerValueChanged() {
		self.userDefaults.set(self.coloredPlayerOption.switchValue, forKey: "colored_player_preference");
		SettingsBundleHelper.appSettingsBundleChanged();
	}
	
	func themeValueChanged(selectedTheme: String) {
		self.userDefaults.set(selectedTheme, forKey: "theme_preference");
		
		let alertController = UIAlertController(title: "Change Theme", message: "Clear the app from memory and run again for changes to take effect.", preferredStyle: UIAlertController.Style.alert);
		alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil));
		self.present(alertController, animated: true, completion: nil);
		//SettingsBundleHelper.appSettingsBundleChanged();
	}
}
