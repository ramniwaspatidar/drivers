

import Foundation
import UIKit

enum ForgotFiledType {
    case password
    case confirmPassword
}

struct ForgotPasswordModel{
    var type : ForgotFiledType
    var placeholder : String
    var value : String
    var header : String

    
    init(type: ForgotFiledType, placeholder: String = "", value: String = "", header : String) {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header

    }
}
