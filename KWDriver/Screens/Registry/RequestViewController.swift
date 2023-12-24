
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class RequestViewController: BaseViewController,Storyboarded, RTCustomAlertDelegate {
    var coordinator: MainCoordinator?
    
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var viewRequestType: UIView!
    @IBOutlet weak var situationLabel: UITextView!
    @IBOutlet weak var serviceTypleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var username: CustomTextField!
    var name: CustomTextField!
    var mobile: CustomTextField!
    var alertTag = 0

    
    
    fileprivate let typeOfService = ["Accident","Emergency","Help"]
    
    enum SignupCellType : Int{
        case username = 0
        case name
        case mobile
    }
    
    var viewModel : RequestViewModel = {
        let model = RequestViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        situationLabel.layer.borderWidth = 1
        situationLabel.layer.borderColor = UIColor.black.cgColor
        situationLabel.layer.cornerRadius = 8
        
        viewRequestType.layer.borderWidth = 1
        viewRequestType.layer.borderColor = UIColor.black.cgColor
        viewRequestType.layer.cornerRadius = 8
        
        situationLabel.text = "Type..."
        
        setupUI()
    }
    
    // SsetupUI
    fileprivate func setupUI(){
        SigninCell.registerWithTable(tblView)
        viewModel.infoArray = (self.viewModel.prepareInfo(dictInfo: viewModel.dictInfo))
//        self.viewModel.addressInfo?[3].value = CurrentUserInfo.phone
//        self.tblView.reloadData()


    }
    
    @IBAction func requestButton(_ sender: Any) {
        RPicker.selectOption(dataArray: typeOfService) { [weak self](str, selectedIndex) in
            self?.viewModel.infoArray[0].value = str
            self!.serviceTypleLabel.text = str
//            self?.tblView.reloadData()
        }
    }
  
    @IBAction func switchAction(_ sender: Any) {
    }
    
    func onClickSubmit(_ alert: RTCustomAlert, alertTag: Int) {
        if(self.alertTag == 0){
            self.alertTag = 1
            let customAlert = RTCustomAlert()
            customAlert.alertTag = 1
            customAlert.delegate = self
            customAlert.show()
        }
        else if(self.alertTag == 1){
            self.alertTag = 2
            let customAlert = RTCustomAlert()
            customAlert.alertTag = 2
            customAlert.delegate = self
            customAlert.show()
        }else{
            coordinator?.goToTrackingView()
        }
    }
    
 
    
    @IBAction func saveButtonAction(_ sender: Any) {
        viewModel.validateFields(dataStore: viewModel.infoArray) { (dict, msg, isSucess) in
            if isSucess {
                
                self.tblView.isHidden = true
                let customAlert = RTCustomAlert()
                customAlert.alertTag = 0
                customAlert.delegate = self
                customAlert.show()
                                
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
extension RequestViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SigninCell.reuseIdentifier, for: indexPath) as! SigninCell
        cell.selectionStyle = .none
        
        switch indexPath.row {
       
        case 0:
            name = cell.textFiled
            name.delegate = self
            name.returnKeyType = .next
            name.text = viewModel.infoArray[2].value
            name.isUserInteractionEnabled = true
            
            
        case 1:
            mobile = cell.textFiled
            mobile.delegate = self
            mobile.returnKeyType = .next
            mobile.text = viewModel.infoArray[3].value
            mobile.keyboardType = .numberPad
            
        default:
            break
        }
        
        cell.commiInit(viewModel.infoArray[indexPath.row + 2])
        
        return cell
    }
}

extension RequestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
}

extension RequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == username{
            name.becomeFirstResponder()
        }
        else   if textField == name{
            name.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let point = tblView.convert(textField.bounds.origin, from: textField)
        let index = tblView.indexPathForRow(at: point)
        let str = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        viewModel.infoArray[(index?.row ?? 0) + 2].value = str ?? ""
        
        return true
    }
}

extension RequestViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = .white
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type..."
            textView.textColor = UIColor.white
        }
        self.viewModel.infoArray[1].value = textView.text
    }
}



