

import UIKit
import SideMenu
import FirebaseMessaging
import CoreLocation

class HomeViewController: BaseViewController,Storyboarded {
    
    
    @IBOutlet weak var taskInday: UILabel!
    @IBOutlet weak var taskinWeek: UILabel!
    @IBOutlet weak var taskStatus: UILabel!
    @IBOutlet weak var viewTask: UIView!
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var appDelegate : AppDelegate?
    var coordinator: MainCoordinator?
    var viewModel : HomeViewModal = {
        let viewModel = HomeViewModal()
        return viewModel }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.setNavWithOutView(ButtonType.menu)
        viewTask.layer.borderWidth = 2
        viewTask.layer.borderColor = hexStringToUIColor("C837AB").cgColor
        viewTask.clipsToBounds = true
        
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
        coordinator = MainCoordinator(navigationController: self.navigationController!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.getDriverInfo() // get drive info
    }
    
    @IBAction func taskButtonAction(_ sender: Any) {
        
        if(CurrentUserInfo.dutyStarted  == false){
            
            let status = CLLocationManager.authorizationStatus()
            
            
            switch status {
                
            case .notDetermined:
                self.appDelegate?.setupLocationManager()

                
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
                self.present(alert, animated: true, completion: nil)
                break
                
            case .authorizedWhenInUse,.authorizedAlways:
                self.appDelegate?.setupLocationManager()
                self.startDutyAction()

                break
                
            default:
                break
            }

            
        }
        else{
            self.startDutyAction()
            
        }
        
    }
    
    
    func startDutyAction(){
        self.viewModel.startDuty(CurrentUserInfo.dutyStarted ? APIsEndPoints.driverEnd.rawValue : APIsEndPoints.driverStart.rawValue, self.viewModel.dictInfo, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    if(CurrentUserInfo.dutyStarted == true){
                        self?.taskButton.backgroundColor = hexStringToUIColor("36D91B")
                        self?.taskButton.setTitle("Start Duty", for: .normal)
                        CurrentUserInfo.dutyStarted = false
                        appDelegate?.stopLocationManager()
                        
                        
                    }else{
                        self?.taskButton.backgroundColor = hexStringToUIColor("FA2A2A")
                        self?.taskButton.setTitle("End Duty", for: .normal)
                        CurrentUserInfo.dutyStarted = true
                        appDelegate?.startGPSTraking()
                    }
                }
            }
        })
    }
    
    
    func getDriverInfo(){
        self.viewModel.getUserData(APIsEndPoints.userProfile.rawValue , self.viewModel.dictInfo, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
                
                self?.bgView.isHidden = false
                DispatchQueue.main.async {
                    CurrentUserInfo.userId = "\(result.driverId ?? "")"
                    CurrentUserInfo.userName = result.fullName
                    CurrentUserInfo.email = result.email
                    CurrentUserInfo.phone = result.phoneNumber
                    
                    Messaging.messaging().subscribe(toTopic: CurrentUserInfo.userId) { error in
                        if let error = error {
                            print("Error subscribing from topic: \(error.localizedDescription)")
                        } else {
                            print("Successfully subscribed from topic!")
                        }
                    }
                    
                    self?.taskinWeek.text = "\(result.requestInWeek ?? 0)"
                    self?.taskInday.text = "\(result.requestInDay ?? 0)"
                    
                    
                    if(result.dutyStarted ?? false){
                        self?.taskButton.backgroundColor = hexStringToUIColor("FA2A2A")
                        self?.taskButton.setTitle("End Duty", for: .normal)
                        CurrentUserInfo.dutyStarted = true
                        
                    }else{
                        self?.taskButton.setTitle("Start Duty", for: .normal)
                        self?.taskButton.backgroundColor = hexStringToUIColor("36D91B")
                        CurrentUserInfo.dutyStarted = false
                        
                    }
                }
            }
        })
        
    }
}

