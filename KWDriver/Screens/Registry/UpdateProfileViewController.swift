

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
    
      var viewModel : UpdateProfileViewModal = {
        let viewModel = UpdateProfileViewModal()
        return viewModel }()
        
    fileprivate lazy var updateProfileModal  : SignupViewModel = {
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
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        phoneTextField.clipsToBounds = true
        phoneTextField.text = dictInfo.phoneNumber
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Enter phone number", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        
        vehicalTextField.layer.borderWidth = 1
        vehicalTextField.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        vehicalTextField.clipsToBounds = true
        vehicalTextField.text = dictInfo.vehicleNumber
        vehicalTextField.layer.cornerRadius = 5
        vehicalTextField.attributedPlaceholder = NSAttributedString(string: "Enter vehical number", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])

        countryCodeView.layer.borderWidth = 1
        countryCodeView.layer.borderColor = hexStringToUIColor("D8A5EC").cgColor
        countryCodeView.clipsToBounds = true
        countryCodeView.layer.cornerRadius = 5
        
    }
    
    
    @IBAction func chooseProfileAction(_ sender: Any) {
        
            ImagePickerManager().pickImage(self){ image in
                self.profileImage.image = image
                self.getProfileImageUploadUrl(image)
        }
    }
    
    
    func getProfileImageUploadUrl(_ img : UIImage){
        self.updateProfileModal.getProfileUploadUrl(APIsEndPoints.kUploadImage.rawValue, handler: {[weak self](result,statusCode)in
            if statusCode ==  0{
                DispatchQueue.main.async {
              
                    self?.uploadImage(result, img.pngData()!, _contentType: "multipart/form-data")
                                                
                }
            }
        })
    }
  
    
    func uploadImage(_ thumbURL:String, _ thumbnail:Data,_contentType:String){
            // Upload Thumbnail & full image on seprate path
        
        let downloadGroup = DispatchGroup()

            let requestURL:URL = URL(string: thumbURL)!
            downloadGroup.enter()
        
        
            NetworkManager.shared.imageDataUploadRequest(requestURL, HUD: false, showSystemError: false, loadingText: false, param: thumbnail, contentType: _contentType) { (sucess, error) in

                print("thumbnail image")
                if (sucess ?? false) == true{
                    let thumbnailURL = thumbURL.split(separator: "?")[0]
                    
                }
                downloadGroup.leave()
            }
                      
        }
    @IBAction func updateProfileAction(_ sender: Any) {
        
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                self.updateUserInfo()
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
                            CurrentUserInfo.userId = result.driverId
                                CurrentUserInfo.userName = result.fullName
                                CurrentUserInfo.email = result.email
                                CurrentUserInfo.phone = "\(countryCode) \(self?.phoneTextField.text ?? "0")"
                            Alert(title: "Update", message: "Profile susscessfully updated", vc: self!)

                                                        
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



