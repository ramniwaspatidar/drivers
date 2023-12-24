
import UIKit

class CustomButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    func commonInit(){
        self.layer.masksToBounds = true

        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        guard let fontName =  self.titleLabel?.font.fontName else {return}
        print(fontName)
        self.titleLabel?.font = self.titleLabel!.font.setFont(fontName, self.titleLabel!.font)
    }
}

@IBDesignable extension CustomButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
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
       var shadowOffset : CGSize{
           
           get{
               return layer.shadowOffset
           }set{
               
               layer.shadowOffset = newValue
           }
       }
       
       @IBInspectable
       var shadowColor : UIColor{
           get{
               return UIColor.init(cgColor: layer.shadowColor!)
           }
           set {
               layer.shadowColor = newValue.cgColor
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


import UIKit
class ActualGradientButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor(red: 0 / 255, green: 87 / 255, blue: 176 / 255, alpha: 1).cgColor,UIColor(red: 0 / 255, green: 154 / 255, blue: 249 / 255 ,alpha: 1).cgColor]

        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = 16
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
@IBDesignable extension ActualGradientButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
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
       var shadowOffset : CGSize{
           
           get{
               return layer.shadowOffset
           }set{
               
               layer.shadowOffset = newValue
           }
       }
       
       @IBInspectable
       var shadowColor : UIColor{
           get{
               return UIColor.init(cgColor: layer.shadowColor!)
           }
           set {
               layer.shadowColor = newValue.cgColor
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
