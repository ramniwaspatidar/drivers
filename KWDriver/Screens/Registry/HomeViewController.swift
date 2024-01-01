

import UIKit
import SideMenu
class HomeViewController: BaseViewController,Storyboarded, locationDelegateProtocol {
    
    @IBOutlet weak var taskInday: UILabel!
    @IBOutlet weak var taskinWeek: UILabel!
    @IBOutlet weak var taskStatus: UILabel!
    @IBOutlet weak var viewTask: UIView!
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    var timer = Timer()
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getDriverInfo() // get drive info
    }
    
    @IBAction func taskButtonAction(_ sender: Any) {
        
        let permission = appDelegate?.checkLocationPermission()// check location permission
        if(permission == true){
            self.startDutyAction() // start duty
        }
    }
    
    func startDutyAction(){
       
        self.viewModel.startDuty(self.viewModel.dutyStarted ? APIsEndPoints.driverEnd.rawValue : APIsEndPoints.driverStart.rawValue, self.viewModel.dictInfo, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
                DispatchQueue.main.async {
                    
                    
                    if(self?.viewModel.dutyStarted ?? false){
                        self?.taskButton.backgroundColor = hexStringToUIColor("36D91B")
                        self?.taskButton.setTitle("Start Duty", for: .normal)
                        self?.viewModel.dutyStarted = false
                        self? .timer.invalidate()
                    
                        
                    }else{
                        self?.taskButton.backgroundColor = hexStringToUIColor("FA2A2A")
                        self?.taskButton.setTitle("End Duty", for: .normal)
                        self?.viewModel.dutyStarted  = true
                        self?.updateLocation() // start location on duty start
                    }
                }
            }
        })
        
    }
    
    
    func updateLocation(){
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true, block: { _ in
            self.appDelegate?.delegate = self
            self.appDelegate?.setupLocationManager()
        })
     
    }
    
    func getUserCurrentLocation() {
        
        var param = [String : Any]()
        let lat = NSString(string:CurrentUserInfo.latitude)
        let lng = NSString(string: CurrentUserInfo.longitude)

        param["latitude"] = lat.doubleValue
        param["longitude"] = lng.doubleValue
        
        self.viewModel.updateDriveLocation( APIsEndPoints.kupdateLocation.rawValue, param, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
               // sucess message
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
                    
                    
                    self?.taskinWeek.text = "\(result.requestInWeek ?? 0)"
                    self?.taskInday.text = "\(result.requestInDay ?? 0)"

                    
                    if(CurrentUserInfo.latitude == nil || CurrentUserInfo.longitude == nil){
                        self?.coordinator?.goToLocation()
                    }else{
                        if(result.dutyStarted ?? false){
                            self?.taskButton.backgroundColor = hexStringToUIColor("FA2A2A")
                            self?.viewModel.dutyStarted = result.dutyStarted ?? false
                            self?.taskButton.setTitle("End Duty", for: .normal)
                            
                        }else{
                            self?.taskButton.setTitle("Start Duty", for: .normal)
                            self?.taskButton.backgroundColor = hexStringToUIColor("36D91B")
                            self?.viewModel.dutyStarted = false
                        }
                    }
                }
            }
        })
        
    }
}

