
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import OTPFieldView

class ArrivalViewControoler: BaseViewController,Storyboarded {
   
    
   
    var coordinator: MainCoordinator?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var arrivalButton: UIView!
    @IBOutlet var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var confirmView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOtpView()
        
        bgView.isHidden = true
        animationView.isHidden = true
        confirmView.isHidden = true

        
    }
    
    func setupOtpView(){
            self.otpTextFieldView.fieldsCount = 6
            self.otpTextFieldView.fieldBorderWidth = 2
            self.otpTextFieldView.filledBorderColor = hexStringToUIColor("#36D91B")
            self.otpTextFieldView.defaultBorderColor = hexStringToUIColor("#9CD4FC")
            self.otpTextFieldView.cursorColor =  hexStringToUIColor("#36D91B")
            self.otpTextFieldView.displayType = .underlinedBottom
            self.otpTextFieldView.fieldSize = 40
            self.otpTextFieldView.separatorSpace = 8
            self.otpTextFieldView.tintColor = hexStringToUIColor("#36D91B")
            self.otpTextFieldView.shouldAllowIntermediateEditing = false
            self.otpTextFieldView.delegate = self
            self.otpTextFieldView.initializeUI()
        }

    @IBAction func arrivalButtonAction
    (_ sender: Any) {
        
        bgView.isHidden = false
        animationView.isHidden = false
        self.confirmView.isHidden = true

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.animationView.isHidden = true
            self.confirmView.isHidden = false
            self.bgView.isHidden = true



        }
        
        
    }
   
    @IBAction func thanksButtonAction(_ sender: Any) {
    }
}
extension ArrivalViewControoler: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        
        if(otpString.count > 5){
//            self.verifyOTP(otpString)
        }
    }
}
