
import Foundation
import UIKit
import ObjectMapper



struct SettingModel{
    var image: UIImage!
    var placeholder : String
    var name : String

    init(image: UIImage , placeholder: String = "", name: String = "") {
        self.image = image
        self.name = name
        self.placeholder = placeholder

    }
}

class SettingViewModel {
    var dictInfo = [String : String]()
    var settingArray = [SettingModel]()
    
    
    func prepareInfo() -> [SettingModel] {
        
        settingArray.append(SettingModel( image: UIImage(named: "home")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Home"))
        
        settingArray.append(SettingModel( image: UIImage(named: "truck_black")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "My Jobs"))
        
        settingArray.append(SettingModel( image: UIImage(named: "truck_black")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Available Jobs"))
        
        
        settingArray.append(SettingModel( image: UIImage(named: "call")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "My Account"))
        
        settingArray.append(SettingModel( image: UIImage(named: "truck_black")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Change Password"))
    
        
        settingArray.append(SettingModel( image: UIImage(named: "privacy")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "T&C"))
        
        settingArray.append(SettingModel( image: UIImage(named: "faq")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "FAQ's"))
        
        settingArray.append(SettingModel( image: UIImage(named: "logout")! , placeholder: NSLocalizedString(LanguageText.number.rawValue, comment: ""), name: "Sign Out"))

        
                
        return settingArray;
        
    }
   
}
