import UIKit
import CoreLocation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import SideMenu

protocol locationDelegateProtocol {
    func getUserCurrentLocation()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var delegate: locationDelegateProtocol? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().unselectedItemTintColor = hexStringToUIColor("#393F45")
        UITabBar.appearance().tintColor = hexStringToUIColor("#E31D7C")
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
                
        
        autoLogin()
        return true
    }
    
    fileprivate func tabbarSetting(){
        UITabBar.appearance().unselectedItemTintColor = hexStringToUIColor("#BABABA")
        UITabBar.appearance().tintColor = hexStringToUIColor("#E31D7C")
        
        // add Shadow
        UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -3)
        UITabBar.appearance().layer.shadowRadius = 3
        UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UITabBar.appearance().layer.shadowOpacity = 1
        UITabBar.appearance().layer.applySketchShadow(color: .white, alpha: 1, x: 0, y: -3, blur: 10)
        
        //        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().layer.borderWidth = 0
        UITabBar.appearance().barTintColor = .white
        
    }
    
    // Mark : get app version
    
    public func autoLogin(){
        

        
        
        
        if ((CurrentUserInfo.userId) != nil) {

            let navController = UINavigationController()
            navController.navigationBar.isHidden = true
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToHome()

        }else{
            let navController = UINavigationController()
            navController.navigationBar.isHidden = true
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToMobileNUmber()
        }
        
//        let navController = UINavigationController()
//        navController.navigationBar.isHidden = true
//        coordinator = MainCoordinator(navigationController: navController)
//        coordinator?.goToMobileNUmber()
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator?.navigationController
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        let sideMenuViewController = SideMenuTableViewController()
            SideMenuManager.default.leftMenuNavigationController = UISideMenuNavigationController(rootViewController: sideMenuViewController)
        sideMenuViewController.coordinator = coordinator

            SideMenuManager.default.addPanGestureToPresent(toView: self.window!)
            SideMenuManager.default.menuWidth = 350

    }
    
    func checkLocationPermission() -> Bool{
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alert = UIAlertController(title: "Allow Location Access", message: "REENERGY needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
                
                // Button to Open Settings
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)")
                        })
                    }
                }))
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                window?.rootViewController?.present(alert, animated: true, completion: nil)
                print("No access")
                return false

            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled")
            return false

        }
        
        return false
    }
    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
        
    }
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        if currentLocation == nil {
           locationManager?.stopUpdatingLocation()
            currentLocation = locations.last
            locationManager?.stopMonitoringSignificantLocationChanges()
            let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
            
            print("locations = \(locationValue)")
            
            CurrentUserInfo.latitude = "\(locationValue.latitude)"
            CurrentUserInfo.longitude = "\(locationValue.longitude)"
            self.delegate?.getUserCurrentLocation()
        //}
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.startUpdatingLocation() // this will access location automatically if user granted access manually. and will not show apple's request alert twice. (Tested)
            break
            
        case .denied:
            manager.stopUpdatingLocation()
            //                if(CurrentUserInfo.location == "" || CurrentUserInfo.location == nil){
            coordinator?.goToLocation()
            //}
            
            break
            
        case .authorizedWhenInUse:
            manager.startUpdatingLocation() //Will update location immediately
            break
            
        case .authorizedAlways:
            manager.startUpdatingLocation() //Will update location immediately
            break
        default:
            break
        }
    }
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
        
}


public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}

func getTopViewController() -> UIViewController? {
    let appDelegate = UIApplication.shared.delegate
    if let window = appDelegate!.window {
        return window?.visibleViewController
    }
    return nil
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.sound]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(#function)")
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        print("\(#function)")
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
    
}
