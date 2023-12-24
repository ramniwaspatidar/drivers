
import Foundation
import UIKit
import ObjectMapper



enum RequestFieldType {
    case service
    case description
    case name
    case mobile
    
}

struct RequestTypeModel{
    var type : RequestFieldType
    var placeholder : String
    var value : String
    var header : String
    
    init(type: RequestFieldType, placeholder: String = "", value: String = "", header : String = "") {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header
    }
}


class RequestViewModel {
    
    var requestModel : RequestModel?
    var dictInfo = [String : String]()
    var infoArray = [RequestTypeModel]()
    let defaultCellHeight = 95
    
    
    func prepareInfo(dictInfo : [String :String])-> [RequestTypeModel]  {
        
        infoArray.append(RequestTypeModel(type: .service, placeholder: NSLocalizedString("Type of service request", comment: ""), value: requestModel?.requestType ?? "", header: "Type of service requested"))
        
        infoArray.append(RequestTypeModel(type: .description, placeholder: NSLocalizedString("Type ...", comment: ""), value: requestModel?.requestType ?? "", header: "Please briefly explain the situation"))
        
        infoArray.append(RequestTypeModel(type: .name, placeholder: NSLocalizedString("Enter name", comment: ""), value: requestModel?.name ?? "", header: "Your Name"))
        
        infoArray.append(RequestTypeModel(type: .mobile, placeholder: NSLocalizedString("Enter mobile number", comment: ""), value: requestModel?.phone ?? CurrentUserInfo.phone ?? "", header: "Your Phone"))
        
       
        
       
        return infoArray
    }
    
   
    func validateFields(dataStore: [RequestTypeModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .service:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Type of service requested", false)
                    return
                }
                
                dictParam["service"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .description:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Please briefly explain the situation", false)
                    return
                }
                
                dictParam["description"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .name:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:], "Enter  name", false)
                    return
                }
                dictParam["name"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .mobile:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Enter mobile number", false)
                    return
                }
                
                dictParam["number"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
         
            }
        }
        
        validHandler(dictParam, "", true)
    }
    
}
