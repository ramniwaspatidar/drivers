

import Foundation
import UIKit

class ChangePasswordViewModal
{
    var dictInfo = [String : String]()
    var infoArray = [ChangePasswordModel]()
    var fromView = ""
    
    func prepareInfo(dictInfo : [String :String])-> [ChangePasswordModel]  {
        
        infoArray.append(ChangePasswordModel(type: .old, placeholder: NSLocalizedString(LanguageText.oldPassword.rawValue, comment: ""), value: "",header: "Old Password"))
        
        infoArray.append(ChangePasswordModel(type: .password, placeholder: NSLocalizedString(LanguageText.newPassword.rawValue, comment: ""), value: "",header: "New Password"))
        
        infoArray.append(ChangePasswordModel(type: .confirmPassword, placeholder:NSLocalizedString( LanguageText.confirmPassword.rawValue, comment: ""), value: "",header: "Confirm Password"))
        
        return infoArray
    }
    
    func validateFields(dataStore: [ChangePasswordModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .old:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.oldPassword.rawValue, comment: ""), false)
                    return
                }
                dictParam["oldPassword"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
                
            case .password:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.enterPassword.rawValue, comment: ""), false)
                    return
                }
                dictParam["newPassword"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .confirmPassword:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.enterConfirmPassword.rawValue, comment: ""), false)
                    return
                }
                
                else if dataStore[index].value.trimmingCharacters(in: .whitespaces) !=  dataStore[1].value.trimmingCharacters(in: .whitespaces) {
                    validHandler([:],NSLocalizedString(LanguageText.samePassword.rawValue, comment: "") , false)
                    return
                }
                dictParam["confirmPassword"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    
}
