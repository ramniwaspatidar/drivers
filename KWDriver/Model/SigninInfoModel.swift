
import Foundation
import UIKit

enum FiledType {
    case email
    case password

}

struct SigninInfoModel{
    var type : FiledType
    var image: UIImage!
    var placeholder : String
    var value : String
    var countryCode : String
    var header : String
    var selected : Bool
    var isValided : Bool


    
    
    init(type: FiledType,image: UIImage , placeholder: String = "", value: String = "", countryCode : String,header: String, selected : Bool, isValided : Bool) {
        self.type = type
        self.image = image
        self.value = value
        self.placeholder = placeholder
        self.countryCode = countryCode
        self.header = header
        self.selected = selected
        self.isValided = isValided

    }
}

public struct RequestModel: Codable {

    var name: String
    var phone: String?
    var requestType : String?
    var description : String?

    enum CodingKeys: String, CodingKey {
        case name
        case phone
        case requestType
        case description

    }

}


public struct AddressModel: Codable {

    var address1: String
    var address2: String?
    var city : String?
    var state : String?
    var landMark : String?

    enum CodingKeys: String, CodingKey {
        case address1
        case address2
        case city
        case state
        case landMark

    }

}

