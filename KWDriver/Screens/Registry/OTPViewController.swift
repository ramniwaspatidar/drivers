

import UIKit
import FirebaseAuth
import OTPFieldView

class OTPViewController: BaseViewController,Storyboarded {
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var bgView: UIView!
    
//    var timer : Timer?
    var dictRequestData : RequestListModal?
    
    var viewModel : LocationViewModel = {
        let model = LocationViewModel()
        return model
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
//            self.bgView.isHidden = true
//            self.animationView.isHidden = false
//        })
     
        self.setNavWithOutView(ButtonType.menu)
        
        let str  : String = "\(dictRequestData?.arrivalCode ?? "")"

        let tempCodeArray = Array(str)
        
        if(tempCodeArray.count > 3){
            lbl1.text = "\(tempCodeArray[0])"
            lbl2.text = "\(tempCodeArray[1])"
            lbl3.text = "\(tempCodeArray[2])"
            lbl4.text = "\(tempCodeArray[3])"
        }
    }
    
    
    @IBAction func markNoShow(_ sender: Any) {
        jobRequestType(APIsEndPoints.kNoShow.rawValue)
    }
    
    func jobRequestType(_ type : String,_ loading : Bool = true){
        let param = [String : String]()
    
        self.viewModel.acceptJob("\(type)\(self.viewModel.dictRequestData?.requestId ?? "")", param,loading) { [weak self](result,statusCode)in
            
            if(statusCode == 0){
                self?.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
    
}


