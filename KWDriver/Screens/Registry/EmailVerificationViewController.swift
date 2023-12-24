

import UIKit
import FirebaseAuth
import OTPFieldView
import SVProgressHUD

class EmailVerificationViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    
    var viewModel : SignupViewModel = {
      let viewModel = SignupViewModel()
      return viewModel }()
    
    fileprivate lazy var updateProfileModal  : SignupViewModel = {
        let viewModel = SignupViewModel()
        return viewModel }()
    
    
    
    @IBOutlet var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var optViewHeight: NSLayoutConstraint!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var headingText: UILabel!
    
    
    var email : String = ""
    var password : String = ""
    var phone : String = ""
    var vehicalID : String = ""
    var isEmailVerification : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavWithOutView(ButtonType.back)

        if(isEmailVerification){
            optViewHeight.constant = 0
            otpTextFieldView.isHidden = true
            self.sendVerificationCode()
        }else{
            headingText.text = "We have sent a 6 digit verification code to +1 \(self.phone). Please enter below."
            self.verifyButton.setTitle("VERIFY PHONE NUMBER", for: .normal)
            setupOtpView()
        }
        
    }
    
    func setupOtpView(){
        self.otpTextFieldView.fieldsCount = 6
        self.otpTextFieldView.fieldBorderWidth = 2
        self.otpTextFieldView.defaultBorderColor = UIColor.white
        self.otpTextFieldView.filledBorderColor = UIColor.white
        self.otpTextFieldView.cursorColor = UIColor.white
        self.otpTextFieldView.displayType = .underlinedBottom
        self.otpTextFieldView.fieldSize = 40
        self.otpTextFieldView.separatorSpace = 8
        self.otpTextFieldView.shouldAllowIntermediateEditing = false
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
    }
    
    @IBAction func resendEmailCode(_ sender: Any) {
        
        if(isEmailVerification){
            self.sendVerificationCode()
            
        }else{ // code to resend otp
            
        }
    }
    @IBAction func emailVerificationAction(_ sender: Any) {
        
        if(isEmailVerification){
            self.verifyEmail()
            
        }else{// code to verification otp
            
            coordinator?.goToLocation()
        }
    }
    
    @IBAction func otpVerifyButton(_ sender: Any) {
    }
    
    func verifyEmail(){
        
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            SVProgressHUD.dismiss()
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                Alert(title: "", message: error.localizedDescription, vc: self)
                
            } else {
                let isVerify = Auth.auth().currentUser?.isEmailVerified ?? false
                self.coordinator?.goToProfile()
                
                if  (isVerify == false) {
                    Alert(title: "Email Verification Failed", message: "We are unable to verify your email address.", vc: self)
                }else{
                }
            }
        }
    }
    
    func verifyOTP(_ code : String){
        var dictParam = [String : String]()
        dictParam["countryCode"] = "+1"
        dictParam["phoneNumber"] = self.phone
        
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
    
    func sendVerificationCode(){
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                
                SVProgressHUD.dismiss()
                if let error = error {
                    print("Error sending verification email: \(error.localizedDescription)")
                    Alert(title: "Email Verification", message: error.localizedDescription, vc: self)
                } else {
                    Alert(title: "Email Verification", message: "We have sent a verification code to your email, Please  verify and continue", vc: self)
                    
                }
            }
        }
    }

    
}



extension EmailVerificationViewController: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        
        if(otpString.count > 5){
            self.verifyOTP(otpString)
        }
        print("OTPString: \(otpString)")
    }
}
