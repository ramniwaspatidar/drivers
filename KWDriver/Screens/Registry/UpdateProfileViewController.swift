import UIKit

class UpdateProfileViewController: BaseViewController,Storyboarded {
    
    @IBOutlet weak var tblView: UITableView!
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var vehicalHeader: UILabel!
    @IBOutlet weak var numberHeader: UILabel!
    @IBOutlet weak var countryCodeView: UIView!
    @IBOutlet weak var nameHeader: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var phoneTextField: CustomTextField!
    @IBOutlet weak var nameTextField: CustomTextField!
    @IBOutlet weak var vehicalTextField: CustomTextField!
    
    var isImageChanged = false
    
    var profileImageUrl = ""
    
    var viewModel : UpdateProfileViewModal = {
        let viewModel = UpdateProfileViewModal()
        return viewModel }()
    
    var updateProfileModal  : SignupViewModel = {
        let viewModel = SignupViewModel()
        return viewModel }()
    
    enum ProfileCellType : Int{
        case name = 0
        case vehical
        case phone
    }
    
    fileprivate let passwordCellHeight = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavWithOutView(.menu)
        
        self.updateProfileModal.getUserData(APIsEndPoints.userProfile.rawValue, self.viewModel.dictInfo, handler: {[weak self](result,statusCode)in
            DispatchQueue.main.async {
                self?.viewModel.infoArray = (self?.viewModel.prepareInfo(dictInfo: result))!
                self?.UISetup(result)
                self?.tblView.isHidden = false
            }
        })
    }
    
    private func UISetup(_ dictInfo : ProfileResponseModel){
        emailLabel.text = CurrentUserInfo.email ?? ""
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        nameTextField.clipsToBounds = true
        nameTextField.text = dictInfo.fullName
        nameTextField.layer.cornerRadius = 5
        nameTextField.keyboardType = .default
        nameTextField.autocorrectionType = .no
        nameTextField.autocapitalizationType = .words
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        phoneTextField.clipsToBounds = true
        phoneTextField.text = dictInfo.phoneNumber
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.keyboardType = .phonePad
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Enter phone number", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        
        vehicalTextField.layer.borderWidth = 1
        vehicalTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        vehicalTextField.clipsToBounds = true
        vehicalTextField.text = dictInfo.vehicleNumber
        vehicalTextField.layer.cornerRadius = 5
        vehicalTextField.keyboardType = .default
        vehicalTextField.autocorrectionType = .no
        vehicalTextField.attributedPlaceholder = NSAttributedString(string: "Enter vehical number", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        countryCodeView.layer.borderWidth = 1
        countryCodeView.layer.borderColor = hexStringToUIColor("D8A5EC").cgColor
        countryCodeView.clipsToBounds = true
        countryCodeView.layer.cornerRadius = 5
        
        if((dictInfo.profileImage) != nil){
            self.profileImageUrl = dictInfo.profileImage ?? ""
            if let url = URL(string: dictInfo.profileImage ?? "") {
                self.profileImage.load(url:url)
            }
            
        }
        
    }
    
    @IBAction func chooseProfileAction(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            self.isImageChanged = true
            self.profileImage.image = image
        }
    }
    
    func getProfileImageUploadUrl(_ img : UIImage){
        self.updateProfileModal.getProfileUploadUrl(APIsEndPoints.kUploadImage.rawValue, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
                self?.uploadImage(result, img.jpegData(compressionQuality: 0.7)!, _contentType: "image/jpeg")
            }
        })
    }
    
    func uploadImage(_ thumbURL:String, _ thumbnail:Data,_contentType:String){
        let requestURL:URL = URL(string: thumbURL)!
        NetworkManager.shared.imageDataUploadRequest(requestURL, HUD: true, showSystemError: false, loadingText: false, param: thumbnail, contentType: _contentType) { (sucess, error) in
            print("thumbnail image")
            if (sucess ?? false) == true{
                let temp = thumbURL.split(separator: "?")
                if let some = temp.first {
                    let value = String(some)
                    self.profileImageUrl = value
                    self.updateUserInfo()
                }
            }
        }
        
    }
    
    @IBAction func updateProfileAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                if(self.isImageChanged){
                    self.getProfileImageUploadUrl(self.profileImage.image!)
                }else{
                    self.updateUserInfo()
                }
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
            var dictParams = dict
            if(self.isImageChanged){
                dictParams["profileImage"] = self.profileImageUrl as AnyObject
            }
            
            if isSucess {
                self.updateProfileModal.updateProfile(APIsEndPoints.ksignupUser.rawValue,dictParams, handler: {[weak self](result,statusCode)in
                    if statusCode ==  0{
                        DispatchQueue.main.async {
                            CurrentUserInfo.userId = result.driverId
                            CurrentUserInfo.userName = result.fullName
                            CurrentUserInfo.email = result.email
                            CurrentUserInfo.phone = self?.phoneTextField.text
                            CurrentUserInfo.vehicleNumber = self?.vehicalTextField.text
                            if(self?.isImageChanged == true){
                                CurrentUserInfo.profileUrl = self?.profileImageUrl
                            }
                            self?.isImageChanged = false
                            AlertWithOkAction(title: "Update", message: "Profile susscessfully updated", vc: self!){ [self] action in
                                
                                if(action == 1){
                                    if(result.isQualified == true){
                                        self?.coordinator?.goToHome(true)
                                    }
                                    else{
                                        self?.coordinator?.goToCodeRequest()
                                    
                                    }
                                }
                            }
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

extension UpdateProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == nameTextField {
            vehicalTextField.becomeFirstResponder()
        }
        else if textField == vehicalTextField {
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
        
        if textField == nameTextField {
            viewModel.infoArray[0].value = str ?? ""
        }
        else if textField == vehicalTextField {
            viewModel.infoArray[1].value = str ?? ""
        }
        else if textField == phoneTextField{
            viewModel.infoArray[2].value = str ?? ""
        }
        return true
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
