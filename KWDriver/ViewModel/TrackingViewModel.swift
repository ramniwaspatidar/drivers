
import Foundation
import UIKit
import ObjectMapper

struct TrackingModel{
    var eta : String
    var value : String
    var color : String
    var status : String
    
    init(eta: String, value: String, color : String,status : String) {
        self.eta = eta
        self.value = value
        self.color = color
        self.status = status
        
    }
}



class TrackingViewModel {
    
    var infoArray = [TrackingModel]()
    let defaultCellHeight = 95
    
    
    func prepareInfo()-> [TrackingModel]  {
        
        infoArray.append(TrackingModel(eta: "08:00 AM", value: "Request Submitted", color: "#9CD4FC", status: "done"))
        infoArray.append(TrackingModel(eta: "Driver Coming", value: "Driver Response ", color: "#F4CC9E", status: "done"))
        infoArray.append(TrackingModel(eta: "ETA - 00:06:05", value: "Help is on the way", color: "#09C655", status: "done"))
        infoArray.append(TrackingModel(eta: "Pending", value: "Help Reached", color: "#DDDBD4", status: "pending"))

        return infoArray
    }
    
    
}
