
import Foundation
import UIKit
import ObjectMapper



class SignupViewModel {
    var dictInfo = [String : String]()
    var infoArray = [SignupInfoModel]()
    var emailInfoDict = [String : Any]()
    
    
    
    func prepareInfo(dictInfo : [String :String])-> [SignupInfoModel]  {
        
        infoArray.append(SignupInfoModel(type: .fullname, image: UIImage(named: "logo") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.name.rawValue, comment: ""), value: emailInfoDict[kName] as? String ?? "", showPassword:  false, iconImage: #imageLiteral(resourceName: "logo"), header: "Full Name"))
        
        infoArray.append(SignupInfoModel(type: .username, image: UIImage(named: "logo") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.email.rawValue, comment: ""), value: emailInfoDict[kEmail] as? String ?? "", showPassword:  false, iconImage: #imageLiteral(resourceName: "logo"), header: "Email"))
        
        infoArray.append(SignupInfoModel(type: .password, image: UIImage(named: "logo") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.enterPassword.rawValue, comment: ""), value: "",showPassword:  false, iconImage: #imageLiteral(resourceName: "logo"), header: "Password"))
        
        infoArray.append(SignupInfoModel(type: .code, image: UIImage(named: "logo") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.invitationCode.rawValue, comment: ""), value: "", showPassword:  false, iconImage: #imageLiteral(resourceName: "logo"), header: "Invitation code"))
        
        return infoArray
    }
    
    func validateFields(dataStore: [SignupInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .fullname:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.name.rawValue, comment: ""), false)
                    return
                }
                dictParam["fullName"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .username:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), false)
                    return
                }
                else if dataStore[index].value.trimmingCharacters(in: .whitespaces).isValidEmail() == false {
                    validHandler([:], NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["email"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .password:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.enterPassword.rawValue, comment: ""), false)
                    return
                }
                
//                else if  (dataStore[index].value.trimmingCharacters(in: .whitespaces).count < 6 ){
//                     validHandler([:], NSLocalizedString(LanguageText.passwordLength.rawValue, comment: ""), false)
//                     return
//                 }
                
                else if dataStore[index].value.trimmingCharacters(in: .whitespaces).isValidPassword() == false{
                    validHandler([:], NSLocalizedString(LanguageText.passwordLength.rawValue, comment: ""), false)
                    return
                }
                
                
                dictParam["password"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
                
            case .code:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], NSLocalizedString(LanguageText.invitationCode.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["code"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
                
            }
        }
        validHandler(dictParam, "", true)
    }
    
    
    
    
public struct SigninResponseModel : Mappable {
        var accessToken : String?
        var refreshToken : String?
        var fullName : String?
        var driverId : String?
        var email : String?
        var code :String?
        var isactive : Bool?
        var message : String?
        
        init?(map: Map) {
            
        }
        
        init() {
            
        }
        
        mutating func mapping(map: Map) {
            accessToken <- map["accessToken"]
            refreshToken <- map["refreshToken"]
            fullName <- map["fullName"]
            driverId <- map["driverId"]
            email <- map["email"]
            code <- map["code"]
            isactive <- map["isactive"]
            message <- map["message"]
            
        }
    }
    
    func registerUser(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (SigninResponseModel,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            print(responce)
            
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<SigninResponseModel>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    handler(SigninResponseModel(),-1)
                }
            }
        })
    }
    
    func updateProfile(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (SigninResponseModel,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.putRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
            print(responce)
            
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<SigninResponseModel>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    handler(SigninResponseModel(),-1)
                }
            }
        })
    }
    func getUserData(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (ProfileResponseModel,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<ProfileResponseModel>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    
                    if(payload["code"] as? Int == 101){
                        handler(ProfileResponseModel(),101)

                    }else{
                        handler(ProfileResponseModel(),-1)

                    }
                }
            }
        })
    }
}
