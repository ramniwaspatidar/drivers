# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'KWDriver' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KWDriver

pod 'Alamofire'
pod 'TPKeyboardAvoidingSwift'
pod 'SDWebImage', '~> 4.0'
pod 'ObjectMapper', '~> 3.4'
pod 'Toast-Swift', '~> 5.0.1'
pod 'SVProgressHUD', '~> 2.2'
pod 'JWTDecode'
pod 'FirebaseAnalytics'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'Firebase/Database'
pod 'Firebase/Core'
pod 'ObjectMapper', '~> 3.5'
pod 'MessageKit'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'OTPFieldView'
pod 'SideMenu'

post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
          end
      end
  end

end
