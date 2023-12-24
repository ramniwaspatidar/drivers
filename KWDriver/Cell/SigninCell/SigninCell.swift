

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
            textFiled.text = dict.value
            textFiled.placeholder = dict.placeholder
            headerLabel.text = dict.header
//            iconImage.image = UIImage(named: dict.header)
            btnViewPassword.isHidden =  dict.type == .password ? false : true
        }
        else if let dict = dictionary as? SignupInfoModel{
            textFiled.text = dict.value
            textFiled.placeholder = dict.placeholder
            headerLabel.text = dict.header

//            iconImage.image = dict.iconImage
        }
        else if let dict = dictionary as? ForgotPasswordModel{
            textFiled.text = dict.value
            textFiled.placeholder = dict.placeholder
            headerLabel.text = dict.header

        }

}

fileprivate func setValue(){
    
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
}

}
