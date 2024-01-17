

import Foundation
import UIKit

class ForgotPasswordViewModel {
    var dictInfo = [String : String]()
    var infoArray = [ForgotPasswordModel]()
    var fromView = ""
    var email : String  = ""
    
    func prepareInfo(dictInfo : [String :String])-> [ForgotPasswordModel]  {
        
        if(fromView == kupdatePassword){
            infoArray.append(ForgotPasswordModel(type: .password, placeholder: NSLocalizedString(LanguageText.oldPassword.rawValue, comment: ""), value: "",header: ""))
            
            infoArray.append(ForgotPasswordModel(type: .confirmPassword, placeholder:NSLocalizedString( LanguageText.newPassword.rawValue, comment: ""), value: "",header: ""))
        }
       else if(fromView == kupdateEmail){
           infoArray.append(ForgotPasswordModel(type: .password, placeholder: NSLocalizedString(LanguageText.email.rawValue, comment: ""), value: "",header: ""))
            
        }
        else{
            infoArray.append(ForgotPasswordModel(type: .password, placeholder: NSLocalizedString(LanguageText.email.rawValue, comment: ""), value: email,header: "Email Address "))
        }
        
       
        
        return infoArray
    }
    
    func validateFields(dataStore: [ForgotPasswordModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
           
                case .password:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.enterPassword.rawValue, comment: ""), false)
                    return
                }
                dictParam["current_customer_email"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
                case .confirmPassword:
                    if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                        validHandler([:], NSLocalizedString(LanguageText.enterConfirmPassword.rawValue, comment: ""), false)
                        return
                    }
                    
                    else if dataStore[index].value.trimmingCharacters(in: .whitespaces) !=  dataStore[0].value.trimmingCharacters(in: .whitespaces) {
                        validHandler([:],NSLocalizedString(LanguageText.samePassword.rawValue, comment: "") , false)
                        return
                    }
                    dictParam["new_password"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    func validateEmailFields(dataStore: [ForgotPasswordModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
           
                case .password:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), false)
                    return
                }
                else if dataStore[index].value.trimmingCharacters(in: .whitespaces).isValidEmail() == false {
                    validHandler([:], NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["current_customer_new_email"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
               dictParam["current_customer_email"] = CurrentUserInfo.email as AnyObject
             
                
                case .confirmPassword:
                    if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                        validHandler([:], NSLocalizedString(LanguageText.confirmEmail.rawValue, comment: ""), false)
                        return
                    }
                    
                    
               
                
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    func validateUpdatePasswordFields(dataStore: [ForgotPasswordModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
           
                case .password:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.oldPassword.rawValue, comment: ""), false)
                    return
                }
              
                
                case .confirmPassword:
                    if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                        validHandler([:], NSLocalizedString(LanguageText.newPassword.rawValue, comment: ""), false)
                        return
                    }
                    
                    dictParam["new_password"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                   dictParam["current_customer_email"] = CurrentUserInfo.email as AnyObject
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    func updatePasswordRequest(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.putRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    handler(message,0)
                }
                else{
                    DispatchQueue.main.async {
                        Alert(title: "", message: message, vc: RootViewController.controller!)
                    }
                }
            }
        })
    }
}
