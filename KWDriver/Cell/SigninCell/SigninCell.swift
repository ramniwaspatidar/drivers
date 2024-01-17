

import UIKit

class SigninCell: ReusableTableViewCell {
    
    @IBOutlet weak var textFiled : CustomTextField!
    @IBOutlet weak var btnViewPassword: UIButton!
    @IBOutlet weak var btnViewPassConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = hexStringToUIColor("E1E3AD").cgColor
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 5
    }
    
    
    func commiInit<T>(_ dictionary :T){
        
        if let dict = dictionary as? SigninInfoModel{
//            headerLabel.textColor = hexStringToUIColor("D8A5EC")
            textFiled.text = dict.value
            textFiled.attributedPlaceholder = NSAttributedString(string: dict.placeholder, attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("D8A5EC")])
            headerLabel.text = dict.header
            btnViewPassword.isHidden =  dict.type == .password ? false : true
        }
        else if let dict = dictionary as? SignupInfoModel{
            textFiled.text = dict.value
            textFiled.attributedPlaceholder = NSAttributedString(string: dict.placeholder, attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("D8A5EC")])
            headerLabel.text = dict.header
            
        }
        else if let dict = dictionary as? ForgotPasswordModel{
            textFiled.attributedPlaceholder = NSAttributedString(string: dict.placeholder, attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("D8A5EC")])
            textFiled.text = dict.value
            headerLabel.text = dict.header
            
        }
        
        else if let dict = dictionary as? ChangePasswordModel{
            textFiled.attributedPlaceholder = NSAttributedString(string: dict.placeholder, attributes: [NSAttributedString.Key.foregroundColor : hexStringToUIColor("FFF")])
            textFiled.text = dict.value
            headerLabel.text = dict.header
            headerLabel.textColor = .white
            
            
        }
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
