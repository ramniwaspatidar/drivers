
import Foundation
import UIKit
import ObjectMapper


enum UpdateProfileFiledType {
    case name
    case vehical
    case phone

}
struct UpdateProfileInfoModel{
    var type : UpdateProfileFiledType
    var placeholder : String
    var value : String
    var header : String

    init(type: UpdateProfileFiledType, placeholder: String , value: String,header: String) {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header

    }
}

class UpdateProfileViewModal {
    var dictInfo = [String : String]()
    var infoArray = [UpdateProfileInfoModel]()
    var isUpdate : Bool = false
    var userNotExist : Bool = false

    var hintImageView: UIImageView!
    var hintImageWidth: NSLayoutConstraint!
    
    var phoneNumberTextFiled: CustomTextField!
    
    func prepareInfo(dictInfo : ProfileResponseModel)-> [UpdateProfileInfoModel]{
        infoArray.append(UpdateProfileInfoModel(type: .name, placeholder: "Enter", value: dictInfo.fullName ?? "", header: "Enter Name"))
        infoArray.append(UpdateProfileInfoModel(type: .vehical, placeholder: "Enter", value: dictInfo.vehicleNumber ?? "", header: "Tag Number"))
        infoArray.append(UpdateProfileInfoModel(type: .phone, placeholder: "Enter", value: dictInfo.phoneNumber ?? "", header: "Phone Number"))

        return infoArray
    }
    
    func validateFields(dataStore: [UpdateProfileInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
                
            case .name:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == ""  {
                    validHandler([:],NSLocalizedString(LanguageText.name.rawValue, comment: ""), false)
                    return
                }
                dictParam["fullName"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
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
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    
    
    
}
