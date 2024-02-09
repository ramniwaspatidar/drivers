
import UIKit
import SideMenu


enum ButtonType {
    case back
    case menu
    case job
}

class BaseViewController: UIViewController {
    
    var backButton : CustomButton!
    var buttonHeight : CGFloat = 40
    var button_y_Axis: CGFloat = 44
    var imgView : UIImageView?
    
    var buttonType : ButtonType?
    var titleLabel : UILabel?
    var logoImage : UIImageView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        imgView?.image = UIImage(named: "bg")
    }
    
  
    func setNavWithOutView(_ type : ButtonType,_ showTitle : Bool = true){
        
        self.buttonType = type
        
        var topBarHeight = 34 + 20
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height >= 812.0 {
            topBarHeight = topBarHeight + 44
        }else{
            topBarHeight = topBarHeight + 64
        }
        
        // menu Button
        backButton = CustomButton(frame: CGRect(x: 16, y: CGFloat((topBarHeight)/2)+11.0 , width: 70, height: 50))
        
        if(type == ButtonType.back ){
            backButton!.addTarget(self, action:#selector(buttonAction), for: .touchUpInside)
            backButton.setImage(UIImage(named: "back"), for: .normal)
            
        }else if(type == ButtonType.job ){
            backButton!.addTarget(self, action:#selector(buttonAction), for: .touchUpInside)
            backButton.setImage(UIImage(named: "job"), for: .normal)
        }
        else{
            backButton!.addTarget(self, action:#selector(buttonAction), for: .touchUpInside)
            backButton.setImage(UIImage(named: "menu"), for: .normal)
        }
        
        
        titleLabel = CustomLabel(frame: CGRect(x: 86.0, y: CGFloat((topBarHeight)/2) + 11.0 , width: self.view.frame.size.width - 172.0, height: 50))
        titleLabel?.font = getSemidFont(20)
        titleLabel?.textAlignment = .center
        titleLabel?.backgroundColor = .clear
        titleLabel?.text = "DRIVER APP"
        titleLabel?.textColor = hexStringToUIColor("F7D63D")
        titleLabel?.font =  UIFont.init(name: ("Reggae One"), size: 20.0)
        
        logoImage = UIImageView(frame: CGRect(x: self.view.frame.size.width - 80, y: CGFloat((topBarHeight)/2)
                                              , width: 72,height: 72))
        logoImage?.image = UIImage(named: "logo")


        self.view.addSubview(backButton!)
        
        if(showTitle == true){
            self.view .addSubview(titleLabel!)
            self.view.addSubview(logoImage!)
        }
        
    }
    

    
    @objc func buttonAction() {
        if(self.buttonType == ButtonType.menu){
            SideMenuManager.default.leftMenuNavigationController?.enableSwipeToDismissGesture = false
            present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
}
