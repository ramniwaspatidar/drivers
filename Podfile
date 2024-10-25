# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'KWDriver' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KWDriver

pod 'SVProgressHUD', '~> 2.2'
pod 'JWTDecode'
pod 'FirebaseAuth'
pod 'Firebase/Core'
pod 'ObjectMapper', '~> 3.5'
pod 'MessageKit'
pod 'Firebase/Messaging'
pod 'OTPFieldView'
pod 'SideMenu'
pod 'IQKeyboardManager'
pod 'FBSDKCoreKit'


  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
end
