
import Foundation
import UIKit

class Attributed{
    
    
    class func setText(_ lbl : UILabel,_ attributrdString : String,_ hexCode : String,_ attributedTextArray : [String],_ font : UIFont){
        lbl.text = attributrdString
        let strAttribute = NSMutableAttributedString(string: attributrdString)
    
        for rangeText in attributedTextArray{
            print(rangeText)
            let range = (attributrdString as NSString).range(of: rangeText)
            strAttribute.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            strAttribute.addAttribute(NSAttributedString.Key.foregroundColor, value:hexStringToUIColor(hexCode), range: range)
        }
        lbl.attributedText = strAttribute
    }
}
