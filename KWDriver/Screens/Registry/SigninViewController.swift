

import UIKit
import FirebaseAuth
import SVProgressHUD
import FirebaseMessaging
import SideMenu

class SigninViewController: UIViewController,Storyboarded {
    
    @IBOutlet weak var signInTablView: UITableView!
    @IBOutlet weak var forgotPasswordLabel: CustomLabel!
    
    var coordinator: MainCoordinator?
    var emailTextField: CustomTextField!
    var passwordTextField: CustomTextField!
    
    fileprivate lazy var viewModel : SigninViewModel = {
        let viewModel = SigninViewModel()
        return viewModel }()
    
    var showPassword: Bool = false {
        didSet {
            if showPassword == false {
                viewModel.infoArray[1].selected =  false
            } else {
                viewModel.infoArray[1].selected =  true
            }
            signInTablView.reloadData()
        }
    }
    
    enum SigninCellType : Int{
        case email = 0
        case password
    }
    fileprivate let passwordCellHeight = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SideMenuManager.default.leftMenuNavigationController = nil

        // MARK : Initial setup
        UISetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func UISetup(){
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        SigninCell.registerWithTable(signInTablView)
        
        forgotPasswordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgotAction(gesture:))))
        
    }
    
    @objc func showPasswordAction() {
        showPassword = showPassword ? false : true
    }
    
    // MARK : button Action
    
    @objc func forgotAction(gesture: UITapGestureRecognizer) {
        
        if(emailTextField.text == ""){
            Alert(title: "Email", message: "Please enter email address", vc: self)
            
        }else{
            coordinator!.goToForgotPassword(emailTextField.text ?? "")
        }
        
    }
    
    
    @IBAction func signinButtonAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.getCurrentUser(self.emailTextField.text ?? "",self.passwordTextField.text ?? "")
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "", message: msg, vc: self)
                }
            }
        }
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        self.coordinator?.goToSignupView()
    }
    
    
    
    func getCurrentUser(_ email : String,_ password : String){
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            SVProgressHUD.dismiss()
            
            if let error = error as NSError? {
                let userInfo = error.userInfo
                let errorType = userInfo["FIRAuthErrorUserInfoNameKey"] as? String
                if(errorType == "ERROR_NETWORK_REQUEST_FAILED") {
                    Alert(title: "", message: "Please check your internet connection and try again.", vc: self)
                }
                else{
                    Alert(title: "", message: "Invalid email or password. Please check your credentials and try again.", vc: self)
                }
                print("Error signing in: \(error.localizedDescription)")
                
            } else {
                
                let isVerify = Auth.auth().currentUser?.isEmailVerified ?? false
                
                if  isVerify == false{
                    self.coordinator?.goToEmailVerificationView(email, password)
                }else{
                    if let user = authResult?.user {
                        self.viewModel.getUserData(APIsEndPoints.userProfile.rawValue, self.viewModel.dictInfo, handler: {[weak self](result,statusCode)in
                            if statusCode ==  0{
                                DispatchQueue.main.async {
                                    if(result.dutyStarted == true){
                                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                        appDelegate?.setupLocationManager()
                                        appDelegate?.startGPSTraking()
                                    }
                                    CurrentUserInfo.dutyStarted = result.dutyStarted
                                    CurrentUserInfo.userId = result.driverId
                                    CurrentUserInfo.userName = result.fullName
                                    CurrentUserInfo.email = result.email
                                    CurrentUserInfo.phone = result.phoneNumber
                                    CurrentUserInfo.profileUrl = result.profileImage
                                    CurrentUserInfo.vehicleNumber = result.vehicleNumber
                                    if(result.phoneNumber == nil || result.vehicleNumber == nil){
                                        self?.coordinator?.goToProfile()
                                    }
                                    else{
                                        self?.coordinator?.goToHome(true)
                                    }
                                }
                            }
                            else{ // in case user not found in db but exist in firebase
                                self?.coordinator?.goToProfile(true)
                            }
                        })
                    }
                }
            }
        }
    }
}



// UITableViewDataSource
extension SigninViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SigninCell.reuseIdentifier, for: indexPath) as! SigninCell
        cell.selectionStyle = .none
        
        
        switch indexPath.row {
            
        case SigninCellType.email.rawValue:
            emailTextField = cell.textFiled
            emailTextField.keyboardType = .emailAddress
            emailTextField.delegate = self
            emailTextField.returnKeyType = .next
            cell.iconImage.image = #imageLiteral(resourceName: "email")
            
            
        case SigninCellType.password.rawValue:
            passwordTextField = cell.textFiled
            passwordTextField.delegate = self
            passwordTextField.isSecureTextEntry  = showPassword ? false : true
            cell.iconImage.image = #imageLiteral(resourceName: "lock")
            cell.btnViewPassword.setImage(showPassword ? #imageLiteral(resourceName: "eye_cross") : #imageLiteral(resourceName: "eye"), for: .normal)
            
        default:
            break
        }
        
        cell.btnViewPassword.addTarget(self, action: #selector(showPasswordAction), for: .touchUpInside)
        cell.commiInit(viewModel.infoArray[indexPath.row])
        
        return cell
    }
}

extension SigninViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(passwordCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = signInTablView.convert(textField.bounds.origin, from: textField)
        let index = signInTablView.indexPathForRow(at: point)
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[(index?.row)!].value = str ?? ""
        
        return true
    }
}



