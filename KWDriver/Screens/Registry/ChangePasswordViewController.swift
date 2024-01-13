
import UIKit
import FirebaseAuth

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
    fileprivate let passwordCellHeight = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
    }
    
    private func UISetup(){
        headerTitle.text = kChangePassword
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
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
            
            user.reauthenticate(with: credential) { (authResult, error) in
                if let error = error {
                    print("Reauthentication failed with error: \(error.localizedDescription)")
                } else {
                    user.updatePassword(to: newPassword) { (error) in
                        if let error = error {
                            print("Password update failed with error: \(error.localizedDescription)")
                        } else {
                            Alert(title: "Change Password", message: "Password updated successfully!", vc: self)
                        }
                    }
                }
            }
        } else {
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
        
        if indexPath.row == ForgotCellType.password.rawValue{
            passwordTextField = cell.textFiled
            passwordTextField.returnKeyType = .next
            passwordTextField.delegate = self
            cell.commiInit(viewModel.infoArray[indexPath.row])
            cell.iconImage.image = #imageLiteral(resourceName: "email")
            
            
            return cell
        }
        confirmPassword = cell.textFiled
        confirmPassword.delegate = self
        cell.commiInit(viewModel.infoArray[indexPath.row])
        cell.iconImage.image = #imageLiteral(resourceName: "email")
        
        
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
        if textField == passwordTextField {
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
