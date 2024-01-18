
import UIKit
import FirebaseAuth
import SVProgressHUD

class ChangePasswordViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var passwordTextField: CustomTextField!
    var confirmPassword: CustomTextField!
    var oldPassword: CustomTextField!
    
    lazy var viewModel : ChangePasswordViewModal = {
        let viewModel = ChangePasswordViewModal()
        return viewModel }()
    
    enum ForgotCellType : Int{
        case old = 0
        case password
        case confirmPassword
    }
    fileprivate let passwordCellHeight = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
    }
    
    private func UISetup(){
        self.setNavWithOutView(.menu)
        viewModel.infoArray = self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo)
        SigninCell.registerWithTable(tblView)
    }
    
    
    @IBAction func applyButtonAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.changePassword()
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "Error", message: msg, vc: self)
                }
            }
        }
    }
        
    func changePassword(){
        if let user = Auth.auth().currentUser {
            let oldPassword = oldPassword.text ?? ""
            let newPassword = confirmPassword.text ?? ""
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPassword)
            
            SVProgressHUD.show()
            
            
            user.reauthenticate(with: credential) { (authResult, error) in
                if let error = error as NSError? {
                    let userInfo = error.userInfo
                    let errorType = userInfo["FIRAuthErrorUserInfoNameKey"] as? String
                    if(errorType == "ERROR_NETWORK_REQUEST_FAILED") {
                        Alert(title: "", message: "Please check your internet connection and try again.", vc: self)
                    }
                    else{
                        Alert(title: "", message: "Old Password not matched. Please check your old password and try again.", vc: self)
                    }
                    print("Reauthentication failed with error: \(error.localizedDescription)")
                    SVProgressHUD.dismiss()
                }
                else {
                    user.updatePassword(to: newPassword) { (error) in
                        SVProgressHUD.dismiss()
                        if let error = error as NSError? {
                            let userInfo = error.userInfo
                            let errorType = userInfo["FIRAuthErrorUserInfoNameKey"] as? String
                            if(errorType == "ERROR_NETWORK_REQUEST_FAILED") {
                                Alert(title: "", message: "Please check your internet connection and try again.", vc: self)
                            }
                            else{
                                Alert(title: "", message: "Password update failed. Please contact to vendor.", vc: self)
                            }
                            print("Password update failed with error: \(error.localizedDescription)")
                        }
                        else {
                            Alert(title: "Change Password", message: "Password updated successfully!", vc: self)
                        }
                    }
                }
            }
        } else {
            SVProgressHUD.dismiss()
            Alert(title: "Error", message: "User not exist", vc: self)
        }
    }
}

// UITableViewDataSource
extension ChangePasswordViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SigninCell.reuseIdentifier, for: indexPath) as! SigninCell
        cell.selectionStyle = .none
        
        
        switch indexPath.row {
            
        case 0:
            oldPassword = cell.textFiled
            oldPassword.delegate = self
            oldPassword.returnKeyType = .next
            oldPassword.isSecureTextEntry = true
        case 1:
            passwordTextField = cell.textFiled
            passwordTextField.isSecureTextEntry = true
            passwordTextField.returnKeyType = .next
            passwordTextField.delegate = self
        
        case 2:
            confirmPassword = cell.textFiled
            confirmPassword.isSecureTextEntry = true
            confirmPassword.returnKeyType = .done
            confirmPassword.delegate = self
            
        default:
            break
        }
        cell.commiInit(viewModel.infoArray[indexPath.row])
        return cell
    }
}

extension ChangePasswordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(passwordCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == oldPassword {
            passwordTextField.becomeFirstResponder()
        }
       else if textField == passwordTextField {
            confirmPassword.becomeFirstResponder()
        }
        else if textField == confirmPassword{
            confirmPassword.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = tblView.convert(textField.bounds.origin, from: textField)
        let index = tblView.indexPathForRow(at: point)
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[(index?.row)!].value = str ?? ""
        return true
    }
}
