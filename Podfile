# Uncomment the next line to define a global platform for your project
platform :ios, '10.2'

target 'veezee' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for veezee
  pod 'SnapKit', '~> 4.0.0'
  pod 'SwiftIcons', '~> 2.0.1'
  pod 'DeviceKit', '~> 1.3.0'
  pod 'CoreAnimator', '~> 2.1.3'
  pod 'Alamofire', '~> 4.6'
  pod 'CodableAlamofire', '~> 1.1.0'
  pod 'CodableExtensions', '~> 0.2.1'
  pod 'Kingfisher', '~> 4.0'
  pod 'PKHUD', '~> 5.0'
  pod 'GoogleSignIn', '~> 4.1.2'
  pod 'Pages', '~> 2.0.2'
  pod 'AnimatedTextInput', '~> 0.5.2'
  pod 'RimhTypingLetters', '~> 0.1.1'
  pod 'SwiftIconFont', '~> 2.7.3'
  pod 'KeychainSwift', '~> 10.0'
  pod 'PMAlertController', '~> 3.2.0'
  pod 'Fabric', '~> 1.7.6'
  pod 'Crashlytics', '~> 3.10.1'
  pod 'NVActivityIndicatorView', '~> 4.2.0'
  pod 'CouchbaseLite-Swift', '~> 2.0.0'
  pod 'Sheeeeeeeeet', '~> 0.9.4'
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'MaterialComponents/Slider', '~> 55.0.4'
  pod 'MarqueeLabel/Swift', '~> 3.1.6'
  pod 'FreeStreamer', '~> 3.8.3'
  pod 'VSInfiniteCarousel', '~> 0.2.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end

