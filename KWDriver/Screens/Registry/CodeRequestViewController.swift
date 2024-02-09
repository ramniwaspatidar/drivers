

import UIKit
import CoreLocation
import SVProgressHUD
import SideMenu

class CodeRequestViewController: BaseViewController,Storyboarded {
   
    
    var coordinator: MainCoordinator?
    let locationManager = CLLocationManager()
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var timerHint: UILabel!
    @IBOutlet weak var timerHintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sendCodeButton: UIButton!
    var isDisable = false
    @IBOutlet weak var largeLogoHeight: NSLayoutConstraint!
    @IBOutlet weak var appNameHeight: NSLayoutConstraint!
    var counter = 86400
    
    var timer : Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
        
        sendCodeButton.isHidden = true

        animationView.isHidden = false
        
        
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height <= 1335 {// small device
            largeLogoHeight.constant = 0
            appNameHeight.constant = 0
            self.setNavWithOutView(.menu,true)
        }
        else{
        self.setNavWithOutView(.menu,false)
        }
        
        
    }
    
    
   
    override func viewDidAppear(_ animated: Bool) {
        
        if(CurrentUserInfo.codeExpiryTime != nil && CurrentUserInfo.codeExpiryTime != 0){
            
            let secondsInADay: TimeInterval = 604800 // 7 days

            let expiryTime: TimeInterval = CurrentUserInfo.codeExpiryTime
            let current: TimeInterval = Date().timeIntervalSince1970
            let differenceInSeconds = current - expiryTime
            print("Difference in seconds:", differenceInSeconds)
            
            let counterTime = Int(secondsInADay - differenceInSeconds)
            
            self.counter = counterTime
            
            
            if(counterTime > 0 ){
                self.isDisable = true
                
                sendCodeButton.alpha = 0.2
                sendCodeButton.isUserInteractionEnabled = false
                
                timerHint.isHidden = false
                timerHintHeight.constant = 24
                
                self.timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)

                // show timer
                
            }else{
                self.isDisable = false
                sendCodeButton.alpha = 1
                sendCodeButton.isUserInteractionEnabled = true
                sendCodeButton.isHidden = false
                
                timerHint.isHidden = true
                timerHintHeight.constant = 0
                
                // enable field to send code
          
            }
        }else{
            sendCodeButton.isHidden = false
            sendCodeButton.alpha = 1
            sendCodeButton.isUserInteractionEnabled = true
            self.sendCodeButton.setTitle("REQUEST CODE", for: .normal)
            
        }

        
    }
    
    
    @objc func updateCounter() {
        //example functionality
        sendCodeButton.isHidden = false

        if counter > 0 {
            
            
            let timeComponents = convertTimeIntervalToHoursMinutesSeconds(timeInterval: TimeInterval(self.counter))
            print("Hours: \(timeComponents.hours), Minutes: \(timeComponents.minutes), Seconds: \(timeComponents.seconds)")
            
            self.sendCodeButton.setTitle("\(timeComponents.hours):\(timeComponents.minutes):\(timeComponents.seconds)", for: .normal)
            print("\(counter) seconds to the end of the world")
            
            counter -= 1
        }
    }
    
    func convertTimeIntervalToHoursMinutesSeconds(timeInterval: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = Int(timeInterval / 3600)
        let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        return (hours, minutes, seconds)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
    @IBAction func requestCodeButtonAction(_ sender: Any) {
        self.sendRequestForCode()
    }
    
    func sendRequestForCode(){
        self.sendCode(APIsEndPoints.kCodeRequest.rawValue, handler: {(mmessage,statusCode)in
            DispatchQueue.main.async {
                
                let currentTimeStampInMilliseconds = Date().timeIntervalSince1970
                CurrentUserInfo.codeExpiryTime = currentTimeStampInMilliseconds
                self.coordinator?.goToVerifyCodeRequest()
            }
        })
    }
    
    func sendCode(_ apiEndPoint: String, handler: @escaping (String,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    handler(message,0)
                }
                else{
                    DispatchQueue.main.async {
                        Alert(title: "", message: message, vc: RootViewController.controller!)
                    }
                }
            }
        })
    }
    
    
    @IBAction func haveCodeButtonAction(_ sender: Any) {
        self.coordinator?.goToVerifyCodeRequest()
    }
}







