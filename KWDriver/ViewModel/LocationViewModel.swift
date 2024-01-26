
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
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = latitude
            center.longitude = longitude

            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)

            ceo.reverseGeocodeLocation(loc, completionHandler:
                {(placemarks, error) in
                    if (error != nil)
                    {
                        print("reverse geodcode fail: \(error!.localizedDescription)")
                    }
                    let pm = placemarks! as [CLPlacemark]

                    if pm.count > 0 {
                        let pm = placemarks![0]
                   
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        
                        if pm.administrativeArea != nil {
                            addressString = addressString + pm.administrativeArea! + ", "
                        }
                        
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "

                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        handler(addressString)
                  }
            })
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
    
    func acceptJob(_ apiEndPoint: String,_ param : [String : Any],_ loading : Bool = true , handler: @escaping (UpdateLocation,Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + apiEndPoint) else {return}
        NetworkManager.shared.postRequest(url, loading, "", params: param, networkHandler: {(responce,statusCode) in
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
    
    


    
}
