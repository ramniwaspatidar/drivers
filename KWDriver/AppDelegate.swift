import UIKit
import CoreLocation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import SideMenu
import IQKeyboardManager

protocol locationDelegateProtocol {
    func getUserCurrentLocation()
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, MessagingDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var delegate: locationDelegateProtocol? = nil
    var timer : Timer?
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().unselectedItemTintColor = hexStringToUIColor("#393F45")
        UITabBar.appearance().tintColor = hexStringToUIColor("#E31D7C")
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        IQKeyboardManager.shared().isEnabled = true

        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        
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
        if CurrentUserInfo.userId != nil, let currentUser = Auth.auth().currentUser {
            let navController = UINavigationController()
            navController.navigationBar.isHidden = true
            coordinator = MainCoordinator(navigationController: navController)
            if(CurrentUserInfo.phone == nil ||  CurrentUserInfo.vehicleNumber == nil){
                coordinator?.goToProfile()
            }
            
            else if(CurrentUserInfo.requestCode == false){
                coordinator?.goToCodeRequest()
            }
            else{
                if(CurrentUserInfo.dutyStarted == true){
                    self.setupLocationManager()
                    self.startGPSTraking()
                }
                
                Messaging.messaging().subscribe(toTopic: currentUser.uid) { error in
                    if let error = error {
                        print("Error subscribing from topic: \(error.localizedDescription)")
                    } else {
                        print("Successfully subscribed from topic!")
                    }
                }
                coordinator?.goToHome()
            }
        }else{
            let navController = UINavigationController()
            navController.navigationBar.isHidden = true
            coordinator = MainCoordinator(navigationController: navController)
            coordinator?.goToMobileNUmber()
        }
        
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
        SideMenuManager.default.menuWidth = (self.window?.rootViewController?.view.frame.size.width ?? 350) - 100
        
    }
    
    func setupLocationManager(){
        if(locationManager != nil){
            stopLocationManager()
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true;
        locationManager?.pausesLocationUpdatesAutomatically = false;
        locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.last
        if let lat = currentLocation?.coordinate.latitude{
            CurrentUserInfo.latitude = "\(lat)"
        }
        if let lng = currentLocation?.coordinate.longitude{
            CurrentUserInfo.longitude = "\(lng)"
        }
    }
    
    func stopLocationManager(){
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        currentLocation = nil
        CurrentUserInfo.latitude = nil
        CurrentUserInfo.longitude = nil
        
        self.timer?.invalidate()
        self.timer = nil
        
    }
    
    func startGPSTraking(){
        if(self.timer != nil){
            self.timer?.invalidate()
            self.timer = nil
        }
        self.updateUserCurrrentLocation()
        self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
            self.updateUserCurrrentLocation()
        })
    }
    
    func updateUserCurrrentLocation() {
        if(CurrentUserInfo.userId != nil && CurrentUserInfo.dutyStarted == true && locationManager != nil) {
            if let lastLocation = currentLocation {
                if lastLocation.coordinate.latitude != 0 && lastLocation.coordinate.longitude != 0 {
                    var param = [String : Any]()
                    param["latitude"] = lastLocation.coordinate.latitude
                    param["longitude"] = lastLocation.coordinate.longitude
                    self.updateDriveLocation( APIsEndPoints.kupdateLocation.rawValue, param, handler: {(result,statusCode)in
                    })
                }
            }
        }
        
    }
    
    func updateDriveLocation(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, false, "", params: param, networkHandler: {(responce,statusCode) in
//            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                
//                print(payload)
            }
        })
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .restricted, .denied:
            let alert = UIAlertController(title: "Allow Location Access", message: "Driver App needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
            
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
            break
            
        case .authorizedWhenInUse,.authorizedAlways:
            manager.startUpdatingLocation()
            break
            
        default:
            break
        }
    }
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
        CurrentUserInfo.latitude = nil
        CurrentUserInfo.longitude = nil
        print("locationManager didFailWithError")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token:", fcmToken ?? "")
        // Send the FCM token to your server if needed
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



@available(iOS 12.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if ((CurrentUserInfo.userId) != nil) {
            let userInfo = response.notification.request.content.userInfo
            let notiType = userInfo["notificationType"] as? String
            if(notiType == "new_request" || notiType == "request_cancelled" || notiType == "confirm_arrival"){
                let requestId = userInfo["requestId"] as? String
                coordinator?.goToJobView(requestId!)
            }
        }
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
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
