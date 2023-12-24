

import Foundation
import UIKit
protocol Storyboarded {
     static func instantiate() -> Self
}

extension Storyboarded where Self : UIViewController{
    
    static func instantiate() -> Self{
        let fullName = NSStringFromClass(self)
        let screenName = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: screenName) as! Self
    }
}
