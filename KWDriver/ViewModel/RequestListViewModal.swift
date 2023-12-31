
import Foundation
import UIKit
import ObjectMapper


struct RequestListModal : Mappable {
    
    
    var  address : String?
    var city : String?
    var country : String?
    var customerId : String?
    var desc : String?
    var latitude : Double?
    var longitude : Double?
    var name : String?
    var phoneNumber : String?
    var typeOfService : String?
    var state : String?
    var requestDate : Double?
    var requestId : String?
    var accepted : Bool = false
    var arrivalCode : String?
    var declineDrivers :[DeclineDrivers]?
    var  driverArrived : Bool = false
    var driverArrivedDate : Double?
    var  confirmArrival : Bool = false
    var confrimArrivalDate : Double?
    var reqDispId : String?
    var cancelled : Bool = false
    var markNoShow : Bool = false
    var driverId : String?
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        address <- map["address"]
        city <- map["city"]
        country <- map["country"]
        customerId <- map["customerId"]
        desc <- map["desc"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        name <- map["name"]
        phoneNumber <- map["phoneNumber"]
        typeOfService <- map["typeOfService"]
        state <- map["state"]
        requestDate <- map["requestDate"]
        requestId <- map["requestId"]
        accepted <- map["accepted"]
        arrivalCode <- map["arrivalCode"]
        declineDrivers <- map["declineDrivers"]
        driverArrived <- map["driverArrived"]
        driverArrivedDate <- map["driverArrivedDate"]
        confirmArrival <- map["confirmArrival"]
        confrimArrivalDate <- map["confrimArrivalDate"]
        reqDispId <- map["reqDispId"]
        cancelled <- map["cancelled"]
        markNoShow <- map["markNoShow"]
        driverId <- map["driverId"]

        
    }
}

struct DeclineDrivers : Mappable {
    
    var  driverId : String?
    var date : String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        driverId <- map["driverId"]
        date <- map["date"]
    }
}




class RequestListViewModal {
    
    var requestModel : RequestModel?
    var listArray = [RequestListModal]()
    let defaultCellHeight = 120
    
    func sendRequest(_ apiEndPoint: String, handler: @escaping ([RequestListModal],Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
            if(statusCode == 200){
                let dictResponce =  Mapper<RequestListModal>().mapArray(JSONArray: responce["payload"] as! [[String : Any]])
                handler(dictResponce,statusCode)
            }
            
            else{
                DispatchQueue.main.async {
                    Alert(title: "", message: "", vc: RootViewController.controller!)
                }
                
            }
        })
    }
    
    
}
