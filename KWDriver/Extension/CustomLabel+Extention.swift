
import Foundation
import UIKit

enum FontName : String {
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case semib = "Semibold"
    case bold = "Bold"
    
}

class CustomLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        let fontName = self.font.fontName
        self.font = self.font.setFont(fontName, self.font)
    }
}

extension UIFont{
    
    func setFont(_ fontType : String,_ font :UIFont) -> UIFont{
        
        if fontName.components(separatedBy: "-").count  == 1{
            return UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue));
        }
        
        let font_tyle = fontName.components(separatedBy: "-")[1]
        
        if font_tyle == FontName.light.rawValue {
            return getLightFont(CGFloat(font.pointSize)) ?? UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue))
        }
        else if  font_tyle == FontName.regular.rawValue {
            return getRegularFont(CGFloat(font.pointSize)) ?? UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue))
        }
        else if  font_tyle == FontName.medium.rawValue {
            return getMediumFont(CGFloat(font.pointSize)) ?? UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue))
        }
        else if  font_tyle == FontName.semib.rawValue {
            return  getSemidFont(CGFloat(font.pointSize)) ?? UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue))
        }
        else if  font_tyle == FontName.bold.rawValue {
            return  getBoldFont(CGFloat(font.pointSize)) ?? UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue))
        }
        return UIFont.systemFont(ofSize: CGFloat(AppFont.size14.rawValue))
    }
    
}

@IBDesignable extension CustomLabel {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            
            layer.shadowRadius = newValue
        }
    }
 
    @IBInspectable
    var shadowOpacity : Float {
        
        get{
            return layer.shadowOpacity
        }
        set {
            
            layer.shadowOpacity = newValue
            
        }
    }
}

extension String{
        func getLabelHeight(_ text : String) -> (CGSize){
        let label = UILabel(frame: CGRect.zero)
               label.text = text
               label.sizeToFit()
        
        return label.frame.size
    }
}
