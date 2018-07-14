# veezee - music streamer (iOS)

<p align="center">
	<img width="50%" src="http://veezee.cloud/demo_assets/veezee-logotype.svg">
</p>
<br>


**veezee** is a cross-platform music streamer inspired by Apple Music and Spotify for **iOS** and **Android**. It is built with **native** technologies for each platform (**Swift** and **Kotlin**). 

*This is the repository for veezee for **iOS**, the **Android** version can be found [here](https://github.com/veezee-music/veezee-android).*

<br>

<p align="center">
  <a href="http://veezee.cloud/demo_assets/ios/p1.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p1.png"></a>
  <a href="http://veezee.cloud/demo_assets/ios/p2.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p2.png"></a>
  <a href="http://veezee.cloud/demo_assets/ios/p3.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p3.png"></a>
</p>
<p align="center">
  <a href="http://veezee.cloud/demo_assets/ios/p4.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p4.png"></a>
  <a href="http://veezee.cloud/demo_assets/ios/p5.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p5.png"></a>
  <a href="http://veezee.cloud/demo_assets/ios/p6.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p6.png"></a>
</p>
<p align="center">
  <a href="http://veezee.cloud/demo_assets/ios/p7.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p7.png"></a>
  <a href="http://veezee.cloud/demo_assets/ios/p8.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p8.png"></a>
  <a href="http://veezee.cloud/demo_assets/ios/p9.png" target="_blank"><img width="32%" src="http://veezee.cloud/demo_assets/ios/p9.png"></a>
</p>




## General features

- Supports tracks, albums, playlists and genres
- User management with email/password and **Google** (Supports cross-device sessions)
- Supports remote (**MongoDB**) and local-offline (**CouchDB**) databases
- **Offline mode**
- **Theme support**
- Sharing

## iOS version features

- Completely written in **Swift 4**
- Optimized for both **iPhone and iPad** (Supports screen resizing)
- Landscape mode (iPad only) - WiP (UI bugs expected)
- **Coded UI** with Autolayout using **Snapkit** (no storyboards or xib files!)
- RxSwift and RxCocoa (limited use)
- High performance audio streamming engine (using Freestreamer)
- Guest mode (Without login)
- Many custom views for different pages
- Beautiful animations using UIKit animations and transitions and UIKit dynamics
- And more...

## Things that ARE planned

- ViewController (VC) for generes
- Complete user accounts VC
- In-app settings (Right now it's located in iOS settings)
- More themes
- More animations
- BUG FIXES!

## Things that are currently NOT planned

- Supporting devices with smaller screens (Current min is 4.7 inches)
- Localization
- Equalizer

## How to use

### Compiling: iOS version

You'll need to use Xcode 9+ and the Cocoapods 1.5+ with the repos up to date.

- Install the dependencies by executing the following command in the project directory in a terminal window: `pod install`
- Rename the `example-app-config.txt` file to `app-config.txt` located in the project root and optionally fill it with API keys for various services supported by veezee


- Open `veezee.xcworkspace` file by double clicking on it or use Xcode file menu to open the project.
- Wait for Xcode to complete the indexing proccess and then build the project using Product -> Build option from the top menu.
- Select a device or simulator with a screen size **equal or larger than 4.7 inch** (e.g. iPhone 8, 8 Plus, X or any iPad) an run the project (For running on a real device you might need to change the application bundle id from Xcode project settings)

### Setting up a server

veezee depends on a functioning HTTPS API server to show music lists and play music as well as do user management and provide analytics data. An incomplete example is provided by the veezee team that can be used as a starting point but it's not completely safe and must be reviewed thoroughly before used in a production environment.

The server can be set up either on the localhost or the Internet. This server's address must be specified in the `Constants.swift` file in the iOS application's project code.



**For more information about the server application please visit [here](https://github.com/veezee-music/veezee-server).**

## License
veezee (iOS) is available under the MIT license. See LICENSE file for more info.
