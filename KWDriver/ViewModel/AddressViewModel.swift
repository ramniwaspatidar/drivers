
import Foundation
import UIKit
import ObjectMapper
import SVProgressHUD
import CoreLocation


enum AddressFieldType {
    case address1
    case city
    case state
    case country
    case postalCode
    case fullAddress
    case landMark

}

struct AddressTypeModel{
    var type : AddressFieldType
    var placeholder : String
    var value : String
    var header : String
    
    init(type: AddressFieldType, placeholder: String = "", value: String = "", header : String = "") {
        self.type = type
        self.value = value
        self.placeholder = placeholder
        self.header = header
    }
}



class AddressViewModel {
    
    var addressModel : AddressModel?
    var dictInfo = [String : String]()
    var infoArray = [AddressTypeModel]()
    var listArray = [DefaultAddress]()
    let defaultCellHeight = 95
    
    struct DefaultAddress : Mappable {
        var addressId : String = ""
        var address : String = ""
        var landmark : String?
        var city : String = ""
        var state : String = ""
        var country : String = ""
        var postalCode : String = ""
        var latitude : Double = 0.0
        var longitude : Double = 0.0
        var fullAddress : String = ""

        init?(map: Map) {

        }
        
        init() {

        }

        mutating func mapping(map: Map) {
            addressId <- map["addressId"]
            address <- map["address"]
            landmark <- map["landmark"]
            city <- map["city"]
            state <- map["state"]
            country <- map["country"]
            postalCode <- map["postalCode"]
            latitude <- map["latitude"]
            longitude <- map["longitude"]
            fullAddress <- map["fullAddress"]
        }
    }
    
    
    func prepareInfo(dictInfo : [String :String])-> [AddressTypeModel]  {
        
        infoArray.append(AddressTypeModel(type: .address1, placeholder: NSLocalizedString("Enter", comment: ""), value: addressModel?.address1 ?? "", header: "Address"))
        
        infoArray.append(AddressTypeModel(type: .city, placeholder: NSLocalizedString("Enter", comment: ""), value: addressModel?.city ?? "", header: "City"))
        
        infoArray.append(AddressTypeModel(type: .state, placeholder: NSLocalizedString("Select", comment: ""), value: addressModel?.state ?? "", header: "State"))
        
        infoArray.append(AddressTypeModel(type: .postalCode, placeholder: NSLocalizedString("Enter", comment: ""), value: "", header: "Postal Code"))
        
        infoArray.append(AddressTypeModel(type: .country, placeholder: NSLocalizedString("Enter", comment: ""), value: "", header: "Country"))
        
        infoArray.append(AddressTypeModel(type: .fullAddress, placeholder: NSLocalizedString("Enter", comment: ""), value:  "", header: "Full Address"))
        
        infoArray.append(AddressTypeModel(type: .landMark, placeholder: NSLocalizedString("Enter", comment: ""), value: "", header: "Land Mark"))
        

        return infoArray
    }
    
   
    func validateFields(dataStore: [AddressTypeModel], validHandler: @escaping (_ param : [String : AnyObject], _ msg : String, _ succes : Bool) -> Void) {
        var dictParam = [String : AnyObject]()
        for index in 0..<dataStore.count {
            switch dataStore[index].type {
                
            case .address1:
//                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
//                    validHandler([:], "Enter  address line1", false)
//                    return
//                }
                dictParam["address1"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject

            case .city:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Enter city name", false)
                    return
                }
                
                dictParam["city"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
                
            case .state:
                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
                    validHandler([:],"Select state type", false)
                    return
                }
                
                dictParam["state"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject
            case .landMark:
//                if dataStore[index].value.trimmingCharacters(in: .whitespaces) == "" {
//                    validHandler([:],"Enter landmark", false)
//                    return
//                }
                dictParam["landmark"] = dataStore[index].value.trimmingCharacters(in: .whitespaces) as AnyObject

            case .country:
                dictParam["country"] = "" as AnyObject

            case .postalCode:
                dictParam["postalCode"] = "" as AnyObject

            case .fullAddress:
                dictParam["fullAddress"] = "" as AnyObject

            }
        }
        
        validHandler(dictParam, "", true)
    }
    
    
    func getAddressFromLatLon(latitude: String, withLongitude longitude: String,handler: @escaping (String) -> Void)  {
        let lat = NSString(string: latitude)
        let lng = NSString(string: longitude)

        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat.doubleValue
        center.longitude = lng.doubleValue
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            self.infoArray[0].value = ""


            
            if pm.count > 0 {
                let pm = placemarks![0]
                
                var addressString : String = ""
                if pm.subThoroughfare != nil {
                    addressString = addressString + pm.subThoroughfare! + ", "
                    self.infoArray[0].value = addressString
                }
                
                if pm.thoroughfare != nil {
                    self.infoArray[0].value = addressString + pm.thoroughfare!
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                    self.infoArray[1].value = pm.locality!
                }
                
                if pm.administrativeArea != nil {
                    addressString = addressString + pm.administrativeArea! + ", "
                    self.infoArray[2].value = pm.administrativeArea!
                }
                
               
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                    self.infoArray[3].value = pm.postalCode!

                }
                
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                    self.infoArray[4].value = pm.country!
                    
                }
                SVProgressHUD.dismiss()
                
                CurrentUserInfo.latitude = "\(pm.location?.coordinate.latitude ?? 0)"
                CurrentUserInfo.longitude = "\(pm.location?.coordinate.longitude ?? 0)"

                self.infoArray[5].value = addressString
                
                handler(addressString)
                
            }else{
                SVProgressHUD.dismiss()
                CurrentUserInfo.latitude = "0"
                CurrentUserInfo.longitude = "0"
                handler("")
            }
        })
        
    }
    func getAddress(_ loading : Bool = true, handler: @escaping ([DefaultAddress],Int) -> Void) {
        guard let url = URL(string: Configuration().environment.baseURL + APIsEndPoints.kGetAddresses.rawValue) else {return}
        NetworkManager.shared.getRequest(url, loading, "", networkHandler: {(responce,statusCode) in
            if(statusCode == 200){
                let dictResponce =  Mapper<DefaultAddress>().mapArray(JSONArray: responce["payload"] as! [[String : Any]])
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
