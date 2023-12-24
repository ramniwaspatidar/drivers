

import UIKit
import FirebaseAuth

class SignupViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    
      var viewModel : SignupViewModel = {
        let viewModel = SignupViewModel()
        return viewModel }()
    @IBOutlet weak var termsLabel: CustomLabel!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var signupTableView: UITableView!
   
    @IBOutlet weak var signupLabel: CustomLabel!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var promotionButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    enum SignupCellType : Int{
        case name = 0
        case email
        case password
        case confirmaPassword
    }
    
    let defaultCellHeight = 90.0
    
    var nameTextField: CustomTextField!
    var emailTextField: CustomTextField!
    var passwordTextField: CustomTextField!
    var confirmPasswordTextFiled: CustomTextField!
    
    var isTermsAccepted: Bool = false {
        didSet {
            if isTermsAccepted == true {
                termsButton.setImage(#imageLiteral(resourceName: "checked_icon"), for: .normal)
            } else {
                termsButton.setImage(#imageLiteral(resourceName: "unchecked_icon"), for: .normal)
            }
            signupTableView.reloadData()
        }
    }
    
    
    var showPassword: Bool = false {
        didSet {
            if showPassword == true {
                passwordTextField.isSecureTextEntry = false
                viewModel.infoArray[1].showPassword =  true
            } else {
                passwordTextField.isSecureTextEntry = true
                viewModel.infoArray[1].showPassword =  false
            }
            setSignUpButtonVisibility()
            
        }
    }
    
    var showConfirmPassword: Bool = false {
        didSet {
            if showPassword == true {
                passwordTextField.isSecureTextEntry = false
                viewModel.infoArray[2].showPassword =  true
            } else {
                passwordTextField.isSecureTextEntry = true
                viewModel.infoArray[2].showPassword =  false
            }
            signupTableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
        
    }
    
    private func UISetup(){
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 30
        bgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                
        viewModel.infoArray = viewModel.prepareInfo(dictInfo: viewModel.dictInfo)
        SigninCell.registerWithTable(signupTableView)
        
        Attributed.setText(termsLabel, kTC, kBlue, [TCService],getBoldFont(CGFloat(AppFont.size14.rawValue))!)
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickTermsLink(gesture:))))
        
        self.setNavWithOutView(ButtonType.back)

        
    }
    
    fileprivate func setSignUpButtonVisibility(){
        if(isTermsAccepted  ){
            signupButton.alpha = 1
            signupButton.isUserInteractionEnabled = true
           
        }else{
            signupButton.alpha = 0.4
            signupButton.isUserInteractionEnabled = false
        }
    }
    
    
    // MARK : Button Action
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)

    }
    @objc func signupAction(gesture: UITapGestureRecognizer) {
        if let range = kSigninlblText.range(of: kSignin),
           gesture.didTapAttributedTextInLabel(label: signupLabel, inRange: NSRange(range, in: kSigninlblText)) {
//            backButtonAction()
        }
    }
    
    @objc func onClickTermsLink(gesture: UITapGestureRecognizer) {
        if let range = kTC.range(of: TCService),
           gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: NSRange(range, in: kTC)) { // open Terms
            coordinator?.goToWebview(type: .TC)
        }
        else if let range = kTC.range(of: TCPolicy),
                gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: NSRange(range, in: kTC)) { // open Policy
            coordinator?.goToWebview(type: .policy)

        }
    }
   
    @IBAction func termsButtonAction(_ sender: Any) {
        isTermsAccepted = !isTermsAccepted
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            
            if isSucess {
                self.viewModel.registerUser(APIsEndPoints.ksignupUser.rawValue,dict, handler: {[weak self](result,statusCode)in
                    if statusCode ==  0{
                        DispatchQueue.main.async {
//                            if let status = result.accessToken, status != "" {
                                CurrentUserInfo.userId = "\(result.driverId ?? "")"
//                                CurrentUserInfo.accessToken = result.accessToken
//                                CurrentUserInfo.refreshToken = result.refreshToken
                                CurrentUserInfo.userName = result.fullName
                                CurrentUserInfo.email = result.email
                            
                            self?.getCurrentUser(self?.viewModel.infoArray[1].value ?? "", self?.viewModel.infoArray[2].value ?? "")
//                                CurrentUserInfo.code = result.code

                          //  }
                            
                        }
                    }
                })
             }
             else {
             Alert(title: "", message: msg, vc: self)
             }
        }
    }
    
    
    func isEmailVerified(_ email : String,_ code :String){
        
        
    }
    
    func getCurrentUser(_ email : String,_ password : String){
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                
                let isVerify = Auth.auth().currentUser?.isEmailVerified ?? false
                
                if  isVerify == false{
                    self.coordinator?.goToEmailVerificationView(email, password)
                }else{
                    // code for next screen
                }
                    
            }
        }
        
    }
}


// UITableViewDataSource
extension SignupViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        let cell  = tableView.dequeueReusableCell(withIdentifier: SigninCell.reuseIdentifier, for: indexPath) as! SigninCell
        cell.selectionStyle = .none
//        cell.textFiled.textColor = .white
        
        switch indexPath.row {
        
        case SignupCellType.name.rawValue:
            nameTextField = cell.textFiled
            nameTextField.delegate = self
            nameTextField.keyboardType = .default
            nameTextField.returnKeyType = .next
            cell.iconImage.image = #imageLiteral(resourceName: "logo")

        
        case SignupCellType.email.rawValue:
            emailTextField = cell.textFiled
            emailTextField.delegate = self
            emailTextField.keyboardType = .emailAddress
            emailTextField.returnKeyType = .next
            cell.iconImage.image = #imageLiteral(resourceName: "email")

            
        case SignupCellType.password.rawValue:
            passwordTextField = cell.textFiled
            passwordTextField.delegate = self
            emailTextField.returnKeyType = .next
            cell.btnViewPassword.setImage(showPassword ? #imageLiteral(resourceName: "eye_cross") : #imageLiteral(resourceName: "eye"), for: .normal)
            cell.iconImage.image = #imageLiteral(resourceName: "lock")

            
        case SignupCellType.confirmaPassword.rawValue:
            confirmPasswordTextFiled = cell.textFiled
            confirmPasswordTextFiled.delegate = self
            cell.btnViewPassword.setImage(showPassword ? #imageLiteral(resourceName: "eye_cross") : #imageLiteral(resourceName: "eye"), for: .normal)
            cell.iconImage.image = #imageLiteral(resourceName: "lock")

        default:
            break
        }
        
        cell.commiInit(viewModel.infoArray[indexPath.row])
        
        
        return cell
    }
}

extension SignupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else   if textField == passwordTextField{
            confirmPasswordTextFiled.becomeFirstResponder()
        }
        else if textField == confirmPasswordTextFiled{
            confirmPasswordTextFiled.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = signupTableView.convert(textField.bounds.origin, from: textField)
        let index = signupTableView.indexPathForRow(at: point)
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[(index?.row)!].value = str ?? ""
        
        
        return true
    }
}
