
import Foundation
import UIKit
import ObjectMapper


enum ProfileFiledType {
    case vehical
    case phone

}
struct ProfileInfoModel{
    var type : ProfileFiledType
    var placeholder : String
    var value : String
    var header : String

    init(type: ProfileFiledType, placeholder: String , value: String,header: String) {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header

    }
}

class ProfileViewModal {
    var dictInfo = [String : String]()
    var infoArray = [ProfileInfoModel]()
    var isUpdate : Bool = false
    var userNotExist : Bool = false

    var hintImageView: UIImageView!
    var hintImageWidth: NSLayoutConstraint!
    
    var phoneNumberTextFiled: CustomTextField!
    
    func prepareInfo(dictInfo : [String :String])-> [ProfileInfoModel]  {
        
        infoArray.append(ProfileInfoModel(type: .vehical, placeholder: "Enter", value: "", header: "Vehical Number"))
        infoArray.append(ProfileInfoModel(type: .phone, placeholder: "Enter", value: "", header: "Phone Number"))

        return infoArray
    }
    
    func validateFields(dataStore: [ProfileInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .vehical:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == ""  {
                    validHandler([:],NSLocalizedString(LanguageText.vehicalNumber.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["vehicleNumber"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .phone:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.entermobilenumber.rawValue, comment: ""), false)
                    return
                }
                else  if !dataStore[index].value.trimmingCharacters(in: .whitespaces).isValidPhoneNumber(){
                    validHandler([:],NSLocalizedString(LanguageText.inValideNumber.rawValue, comment: ""), false)
                    return
                }
                dictParam["phoneNumber"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                dictParam["userNotExist"] = userNotExist as AnyObject
                dictParam["fullName"] = CurrentUserInfo.userName as AnyObject
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    
    
    
}
