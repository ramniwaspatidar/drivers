

import Foundation


final class AppGuide {
    
    private enum AppGuideType: String {
        case orderType
    }
    
    static var orderType: String! {
        get {
            return UserDefaults.standard.string(forKey: AppGuideType.orderType.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = AppGuideType.orderType.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}

