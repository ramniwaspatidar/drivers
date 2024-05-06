
import Foundation
import UIKit
import ObjectMapper
import CoreLocation



class LocationViewModel {
    var dictInfo = [String : String]()
    var emailInfoDict = [String : Any]()
    
    var dictRequestData : RequestListModal?

    struct UpdateLocation : Mappable {
        var accessToken : String?
        var refreshToken : String?
        var code :String?

        var message : String?

        init?(map: Map) {

        }
        
        init() {

        }

        mutating func mapping(map: Map) {
            accessToken <- map["accessToken"]
            refreshToken <- map["refreshToken"]
            code <- map["code"]
            message <- map["message"]

        }
    }
    
    func getAddressFromLatLon(latitude: Double, withLongitude longitude: Double ,handler: @escaping (String) -> Void)  {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let ceo = CLGeocoder()
        let loc = CLLocation(latitude: center.latitude, longitude: center.longitude)

        ceo.reverseGeocodeLocation(loc) { (placemarks, error) in
            if let error = error {
                print("Reverse geocode fail: \(error.localizedDescription)")
                handler("") // Return empty string in case of error
                return
            }

            guard let placemarks = placemarks, let pm = placemarks.first else {
                print("No placemarks found")
                handler("") // Return empty string if no placemarks are found
                return
            }

            var addressString = ""
            if let subLocality = pm.subLocality {
                addressString += subLocality + ", "
            }
            if let thoroughfare = pm.thoroughfare {
                addressString += thoroughfare + ", "
            }
            if let locality = pm.locality {
                addressString += locality + ", "
            }
            if let administrativeArea = pm.administrativeArea {
                addressString += administrativeArea + ", "
            }
            if let country = pm.country {
                addressString += country + ", "
            }
            if let postalCode = pm.postalCode {
                addressString += postalCode + " "
            }

            handler(addressString)
        }
    }

    
    func updateDriveLocation(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (UpdateLocation,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, true, "", params: param, networkHandler: {(responce,statusCode) in
//            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<UpdateLocation>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    handler(UpdateLocation(),-1)
                }
            }
        })
    }
    
    func strartJob(_ apiEndPoint: String,_ param : [String : Any], handler: @escaping (UpdateLocation,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, true, "", networkHandler: {(responce,statusCode) in
//            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<UpdateLocation>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    handler(UpdateLocation(),-1)
                }
            }
        })
    }
    
    func getRequestData(_ apiEndPoint: String,_ loading : Bool = true, handler: @escaping (RequestListModal,Int) -> Void) {
        
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.getRequest(url, loading, "", networkHandler: {(responce,statusCode) in
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<RequestListModal>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    DispatchQueue.main.async {
                        Alert(title: "", message: message, vc: RootViewController.controller!)
                    }
                }
            }
        })
    }
    
    func acceptJob(_ apiEndPoint: String,_ param : [String : Any],_ loading : Bool = true , handler: @escaping (RequestListModal,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, loading, "", params: param, networkHandler: {(responce,statusCode) in
//            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<RequestListModal>().map(JSON: payload)
                    handler(dictResponce!,0)
                }
                else{
                    DispatchQueue.main.async {
                        Alert(title: "", message: message, vc: RootViewController.controller!)
                    }
                }
            }
        })
    }
    
    func handoverRequest(_ apiEndPoint: String,_ param : [String : Any],_ loading : Bool = true , handler: @escaping (RequestListModal,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, loading, "", params: param, networkHandler: {(responce,statusCode) in
//            print(responce)
            APIHelper.parseObject(responce, true) { payload, status, message, code in
                if status {
                    let dictResponce =  Mapper<RequestListModal>().map(JSON: payload)
                    handler(dictResponce!,0)
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
