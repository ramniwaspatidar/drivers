

import UIKit

class ProfileViewController: BaseViewController,Storyboarded {
    
    @IBOutlet weak var signInTablView: UITableView!
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var vehicalHeader: UILabel!
    @IBOutlet weak var numberHeader: UILabel!
    
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var vehicalTextField: CustomTextField!
    @IBOutlet weak var countryCodeView: UIView!
    
    fileprivate lazy var viewModel : ProfileViewModal = {
        let viewModel = ProfileViewModal()
        return viewModel }()
    
    
    
    fileprivate lazy var updateProfileModal  : SignupViewModel = {
        let viewModel = SignupViewModel()
        return viewModel }()
    
    
    enum ProfileCellType : Int{
        case vehical = 0
        case phone
    }
    
    fileprivate let passwordCellHeight = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetup()
    }

    private func UISetup(){
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = hexStringToUIColor("D8A5EC").cgColor
        phoneTextField.clipsToBounds = true
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Enter phone number", attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("D8A5EC")])
        
        
        vehicalTextField.layer.borderWidth = 1
        vehicalTextField.layer.borderColor = hexStringToUIColor("D8A5EC").cgColor
        vehicalTextField.clipsToBounds = true
        vehicalTextField.layer.cornerRadius = 5
        vehicalTextField.attributedPlaceholder = NSAttributedString(string: "Enter vehical number", attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("D8A5EC")])
        
//        vehicalTextField.attributedPlaceholder = NSAttributedString(string: "Enter" , attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.cgColor])
//        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Enter", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.cgColor])

        
        countryCodeView.layer.borderWidth = 1
        countryCodeView.layer.borderColor = hexStringToUIColor("D8A5EC").cgColor
        countryCodeView.clipsToBounds = true
        countryCodeView.layer.cornerRadius = 5
        
        
        
        
        
        
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
    }
    
    
    @IBAction func chooseProfileAction(_ sender: Any) {
        
            ImagePickerManager().pickImage(self){ image in
                self.profileImage.image = image
            
        }
    }
    @IBAction func submitButtonAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.updateUserInfo()
//                self.coordinator?.goToEmailVerificationView("", self.phoneTextField.text ?? "",self.phoneTextField.text ?? "",false)
            }
            else {
                DispatchQueue.main.async {
                    Alert(title: "", message: msg, vc: self)
                }
            }
        }
    }
    

    
    func updateUserInfo() {

        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            
            if isSucess {
                self.updateProfileModal.updateProfile(APIsEndPoints.ksignupUser.rawValue,dict, handler: {[weak self](result,statusCode)in
                    if statusCode ==  0{
                        DispatchQueue.main.async {
                                CurrentUserInfo.userId = "\(result.driverId ?? "")"
//                                CurrentUserInfo.accessToken = result.accessToken
//                                CurrentUserInfo.refreshToken = result.refreshToken
                                CurrentUserInfo.userName = result.fullName
                                CurrentUserInfo.email = result.email
                                CurrentUserInfo.phone = "+1 \(self?.phoneTextField.text ?? "0")"
                            
                            self?.coordinator?.goToHome()
                            

                            
                        }
                    }
                })
             }
             else {
             Alert(title: "", message: msg, vc: self)
             }
        }

   }
    
   
}



extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == vehicalTextField {
            phoneTextField.becomeFirstResponder()
        }
        else if textField == phoneTextField{
            phoneTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        
        if textField == vehicalTextField {
            viewModel.infoArray[0].value = str ?? ""
        }
        else if textField == phoneTextField{
            viewModel.infoArray[1].value = str ?? ""
        }
        
        return true
    }
}



