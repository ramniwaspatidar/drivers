

import UIKit
import FirebaseAuth
import FirebaseFirestore
import OTPFieldView

class OTPViewController: UIViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    var verificationID : String?
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl1.text = "1"
        lbl2.text = "6"
        lbl3.text = "3"
        lbl4.text = "8"
        lbl5.text = "9"
        lbl6.text = "6"
    }
    
    
    @IBAction func markNoShow(_ sender: Any) {
    }
    func verifyOTP(_ code : String){
        var dictParam = [String : String]()
        dictParam["countryCode"] = "+1"
        
        self.verifyOTP(APIsEndPoints.ksignupUser.rawValue,dictParam, handler: {(mmessage,statusCode)in
            DispatchQueue.main.async {
                self.coordinator?.goToProfile()
                
            }
        })
    }
    
    func verifyOTP(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    
                    let customerId = payload["customerId"] as? String
                    let number = payload["fullNumber"] as? String
                    CurrentUserInfo.userId = customerId
                    CurrentUserInfo.phone = number

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
    
}


