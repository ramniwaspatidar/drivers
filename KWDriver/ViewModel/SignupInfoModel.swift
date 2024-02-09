

import Foundation
import UIKit

enum SignFiledType {
    case fullname
    case username
    case password
//    case code
}


struct SignupInfoModel{
    var type : SignFiledType
    var image: UIImage!
    var placeholder : String
    var value : String
    var showPassword : Bool
    var iconImage : UIImage
    var header : String
    
    init(type: SignFiledType,image: UIImage , placeholder: String = "", value: String = "", showPassword : Bool, iconImage : UIImage, header :String) {
        self.type = type
        self.image = image
        self.value = value
        self.placeholder = placeholder
        self.showPassword = showPassword
        self.iconImage = iconImage
        self.header = header
    }
}
