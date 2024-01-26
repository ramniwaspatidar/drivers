
import Foundation
import UIKit
import ObjectMapper




struct StartdutyModal : Mappable {
    var accessToken : String?
    var refreshToken : String?
    var isactive : Bool?
    var message : String?

    init?(map: Map) {

    }
    
    init() {

    }

    mutating func mapping(map: Map) {
        accessToken <- map["accessToken"]
        refreshToken <- map["refreshToken"]
        isactive <- map["isactive"]
        message <- map["message"]
    }
}


class HomeViewModal {
    var dictInfo = [String : String]()
    
    
    var hintImageView: UIImageView!
    var hintImageWidth: NSLayoutConstraint!
    
    var dutyStarted : Bool = false
    
    var phoneNumberTextFiled: CustomTextField!
    
    var dictRequest : ProfileResponseModel?
    
   
  
    
    func startDuty(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (String,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}

        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
//            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    handler("",0)
                }
                else{
                    handler("",-1)
                }
            }
        })
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
                    handler(ProfileResponseModel(),-1)
                }
            }
        })
    }

    
}
