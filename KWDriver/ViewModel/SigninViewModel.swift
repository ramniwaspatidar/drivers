
import Foundation
import UIKit
import ObjectMapper


struct UserNotExist : Mappable {
    var message : String?
     var code : Int?

    init?(map: Map) {

    }
    
    init() {

    }

    mutating func mapping(map: Map) {
        message <- map["message"]
        code <- map["code"]
    }
}



struct ProfileResponseModel : Mappable {
    var accessToken : String?
    var refreshToken : String?
    var fullName : String?
    var driverId : String?
    var email : String?
    var code :String?
    var phoneNumber : String?
    var isactive : Bool?
    var message : String?
    var vehicleNumber : String?
    var dutyStarted : Bool?
    var requestInWeek : Int?
    var requestInDay : Int?
    var profileImage : String?

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
        phoneNumber <- map["phoneNumber"]
        vehicleNumber <- map["vehicleNumber"]
        dutyStarted <- map["dutyStarted"]
        requestInWeek <- map["requestInWeek"]
        requestInDay <- map["requestInDay"]
        profileImage <- map["profileImage"]
    }
}



class SigninViewModel {
    var dictInfo = [String : String]()
    var infoArray = [SigninInfoModel]()
    
    
    var hintImageView: UIImageView!
    var hintImageWidth: NSLayoutConstraint!
    
    var phoneNumberTextFiled: CustomTextField!
    
    func prepareInfo(dictInfo : [String :String])-> [SigninInfoModel]  {
        
        infoArray.append(SigninInfoModel(type: .email, image: UIImage(named: "profilePlaceholder") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), value: "", countryCode: "", header: "Email",selected: false, isValided:false))
        
        infoArray.append(SigninInfoModel(type: .password, image: UIImage(named: "profilePlaceholder") ??  #imageLiteral(resourceName: "logo"), placeholder: NSLocalizedString(LanguageText.enterPassword.rawValue, comment: ""), value: "", countryCode: "", header: "Password",selected: false, isValided:false))
        return infoArray
    }
    
    func validateFields(dataStore: [SigninInfoModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .email:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" || !dataStore[index].value.trimmingCharacters(in: .whitespaces).isValidEmail() {
                    validHandler([:],NSLocalizedString(LanguageText.emailEnter.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["email"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .password:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == ""{
                    validHandler([:], NSLocalizedString(LanguageText.enterPassword.rawValue, comment: ""), false)
                    return
                }
                else if  (dataStore[index].value.trimmingCharacters(in: .whitespaces).count < 6 ){
                    validHandler([:], NSLocalizedString(LanguageText.passwordLengthMessageForSignIn.rawValue, comment: ""), false)
                    return
                }
                
                dictParam["password"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
                
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    func getUserData(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (ProfileResponseModel,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
//            print(responce)
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
