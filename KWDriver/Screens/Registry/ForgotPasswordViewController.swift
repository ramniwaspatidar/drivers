
import UIKit

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
        case confirmPassword
    }
    fileprivate let passwordCellHeight = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
    }
    
    private func UISetup(){
        
        self.setNavWithOutView(ButtonType.back)
        
        if(viewModel.fromView == kupdatePassword){
            headerTitle.text = kupdatePassword
        }
        else if (viewModel.fromView == kupdateEmail){
            headerTitle.text = kupdateEmail
        }
        
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
        SigninCell.registerWithTable(tblView)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func applyButtonAction(_ sender: Any) {
        updatePassword()

//        if(viewModel.fromView == kupdatePassword){
//            updatePassword()
//        }else  if(viewModel.fromView == kupdateEmail){
//            updateEmail()
//        }
    }
    
    
    
    func updatePassword(){
        
        viewModel.validateEmailFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
//                self.viewModel.updatePasswordRequest(APIsEndPoints.updatePassword.rawValue,dict, handler: {(mmessage,statusCode)in
//                    DispatchQueue.main.async {
//                        Alert(title: "", message: mmessage, vc: RootViewController.controller!)
//
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                })
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "", message: msg, vc: self)
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
