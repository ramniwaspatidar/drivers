

import UIKit
import SVProgressHUD

class VerifyRequestCodeController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    
    fileprivate lazy var updateProfileModal  : SignupViewModel = {
        let viewModel = SignupViewModel()
        return viewModel }()
    
    var requestCode : String = ""
    @IBOutlet weak var codeTextField: CustomTextField!
    
    override func viewDidLoad() {
        
        codeTextField.layer.borderWidth = 1
        codeTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        codeTextField.clipsToBounds = true
        codeTextField.layer.cornerRadius = 5
        
        codeTextField.attributedPlaceholder = NSAttributedString(string: "Enter invitation code", attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("D8A5EC")])
        
        self.setNavWithOutView(.back,false)
        super.viewDidLoad()
    }
    
    
    @IBAction func codeVerificationAction(_ sender: Any) {
        if(codeTextField.text == "" || codeTextField.text?.count ?? 0 != 6){
            Alert(title: "Request Code", message: "The request code should not be empty and should consist of 6 digits.", vc: self)
            
        }else{
            self.verifyOTP(codeTextField.text ?? "")
        }
    }
    
    
    func verifyOTP(_ code : String){
        var dictParam = [String : String]()
        dictParam["code"] = code
        
        self.verifyOTP(APIsEndPoints.kVerifyCode.rawValue,dictParam, handler: {(mmessage,statusCode)in
            DispatchQueue.main.async {
                CurrentUserInfo.requestCode = true
                CurrentUserInfo.codeExpiryTime = 0
                self.coordinator?.goToHome(true)
            }
        })
    }
    
    func verifyOTP(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
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
    
}
extension VerifyRequestCodeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == codeTextField{
            codeTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
    }
}



