

import UIKit

class UserNameCell: ReusableTableViewCell {
    
    @IBOutlet weak var textFiled : CustomTextField!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func commiInit<T>(_ dictionary :T){
        if let dict = dictionary as? SigninInfoModel{
            textFiled.text = dict.value
            textFiled.placeholder = dict.placeholder
        }
    }
    
    fileprivate func setValue(){
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
