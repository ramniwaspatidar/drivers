
import UIKit
import FirebaseAuth
import SVProgressHUD

class ForgotPasswordViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    
    
    var passwordTextField: CustomTextField!
    var confirmPassword: CustomTextField!
    
    lazy var viewModel : ForgotPasswordViewModel = {

        let viewModel = ForgotPasswordViewModel()
        return viewModel }()
    
    enum ForgotCellType : Int{
        case password = 0
    }
    fileprivate let passwordCellHeight = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
    }
    
    private func UISetup(){
        
        self.setNavWithOutView(ButtonType.back,false)
        
        if(viewModel.fromView == kupdatePassword){
            headerTitle.text = kupdatePassword
        }
        else if (viewModel.fromView == kupdateEmail){
            headerTitle.text = kupdateEmail
        }
        
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        SigninCell.registerWithTable(tblView)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        updatePassword()
    }
    
    
    
    func updatePassword(){
        let email = viewModel.infoArray[0].value 
        
        if (email == "" ||   email.trimmingCharacters(in: .whitespaces).isValidEmail() == false){
                Alert(title: "", message: "Enter email address", vc: self)
        }else{
            resetPassword(email)
        }
    }
    
    
    func resetPassword(_ email : String) {
     
        SVProgressHUD.show()

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
            SVProgressHUD.dismiss()

            if let error = error {
                // Handle the error
                print("Error sending password reset email: \(error.localizedDescription)")
            } else {
                // Password reset email sent successfully
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: false)
                    Alert(title: "Reset Password", message: "Password reset email sent successfully. Check your email inbox.", vc: self)
                }
            }
        }
    }
    
}

// UITableViewDataSource
extension ForgotPasswordViewController: UITableViewDataSource {
    
    
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

extension ForgotPasswordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(passwordCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
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
