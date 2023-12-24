

import Foundation
import UIKit

    // Mark : Alert Controller
    
    func Alert(title: String, message:String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message,    preferredStyle: .alert)
        let okAction = UIAlertAction(title: kOk, style: .default, handler: nil)
        alert.addAction(okAction)
        alert.view.tintColor = hexStringToUIColor(kDarkBlue)
        vc.present(alert, animated: true, completion: nil)
    }
    
func AlertWithAction(title: String, message:String,_ buttons : [String], vc: UIViewController, alterHandller : @escaping (Int) -> (Void)) {
        let alert = UIAlertController(title: title, message: message,    preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttons[0], style: .default, handler: {(action)in
            alterHandller(1)
        })
        
    if buttons.count > 1
    {
        let cancelAction = UIAlertAction(title: buttons[1], style: .cancel, handler: nil)
        alert.addAction(cancelAction)
    }

        alert.addAction(okAction)
        
        alert.view.tintColor = hexStringToUIColor(kBlue)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    // Font Size
    
    func getRegularFont(_ size: CGFloat) -> UIFont? {
        return UIFont(name: kFontTextRegular, size: size)
    }
    func getBoldFont(_ size: CGFloat) -> UIFont? {
           return UIFont(name: kFontTextBold, size: size)
       }
    func getSemidFont(_ size: CGFloat) -> UIFont? {
        return UIFont(name: kFontTextSemibold, size: size)
    }
    func getMediumFont(_ size: CGFloat) -> UIFont? {
        return UIFont(name: kFontTextMedium, size: size)
    }
    func getLightFont(_ size: CGFloat) -> UIFont? {
        return UIFont(name: kFontTextLight, size: size)
    }
    
    // Hex Color code
    
    func hexStringToUIColor(_ hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    

class AppUtility: NSObject {

    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    class func deviceUDID() -> String {
        var udidString = ""
        if let udid = UIDevice.current.identifierForVendor?.uuidString {
            udidString = udid
        }
        return udidString
    }
    
    // Date from unix timestamp from Date
    class func date(timestamp: Double) -> Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    class func getStoryBoard(storyBoardName: String) -> UIStoryboard {
        return  UIStoryboard(name: storyBoardName, bundle:nil)
    }
    
    class func getDateFormTimeStamp() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZ"
        dateFormatter.timeZone = NSTimeZone.local
        let dateString: String = dateFormatter.string(from: date)
        return dateString
    }
    
   class func getStringFromDate(date : Date) -> String {
        
        let dateFormat = DateFormatter.init()
        dateFormat.timeZone = NSTimeZone.local
        dateFormat.dateFormat = "MM/dd/yyyy"
        return dateFormat.string(from: date)
    }
    
    class func getdayFromDate(date : Date) -> String {
        
        let dateFormat = DateFormatter.init()
        dateFormat.timeZone = NSTimeZone.local
        dateFormat.dateFormat = "dd MMM"
        return dateFormat.string(from: date)
    }
    
   class func dateToString(date : Date) -> String {
        let dateFormat = DateFormatter.init()
        dateFormat.timeZone = NSTimeZone.local
       dateFormat.dateFormat = "dd MMM YYYY"

        return dateFormat.string(from: date)
    }
    
   class func getDateFromString(_ dateString : String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM YYYY"
        let date = dateFormatter.date(from:dateString)
        return date!
    }
    
    class func getPostDateFromString(_ dateString : String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from:dateString)
        return date ?? Date()
    }
    
    class func getSlotDateFromString(_ dateString : String) -> Date{
        let strDate = dateString.replacingOccurrences(of: "T", with: " ")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let date = dateFormatter.date(from:strDate)
        return date ?? Date()
    }
    
    class func makeCornerRoundBottom(_ view : UIView){
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    class func addSubview(subView: UIView, toView parentView: UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }
    
    class func leftBarButton(_ imageName : String, controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setImage(UIImage(named: imageName as String), for: UIControl.State())
        button.addTarget(controller, action:#selector(leftBarButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        NSLayoutConstraint.activate([(leftBarButtonItem.customView!.widthAnchor.constraint(equalToConstant: 40)),(leftBarButtonItem.customView!.heightAnchor.constraint(equalToConstant: 40))])

        return leftBarButtonItem
    }
    
    class func rightBarButton(_ imageName : String, controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setImage(UIImage(named: imageName as String), for: UIControl.State())
        button.addTarget(controller, action:#selector(rightBarButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        NSLayoutConstraint.activate([(rightBarButtonItem.customView!.widthAnchor.constraint(equalToConstant: 40)),(rightBarButtonItem.customView!.heightAnchor.constraint(equalToConstant: 40))])

        return rightBarButtonItem
    }
    
    class func leftTitleBarButton(_ title : String, controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 10, y: 10, width: 80, height: 30)
        button.setTitle(title, for: UIControl.State())
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(controller, action:#selector(leftBarButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        return leftBarButtonItem
    }
    
    class func rightTitleBarButton(_ title : String, controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 10, y: 10, width: 80, height: 30)
        button.setTitle(title, for: UIControl.State())
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(controller, action:#selector(rightBarButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let rightBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        return rightBarButtonItem
    }
    
    class func isUpdateAvailable() throws -> Bool {
               guard let info = Bundle.main.infoDictionary,
                   let currentVersion = info["CFBundleShortVersionString"] as? String,
                   let identifier = info["CFBundleIdentifier"] as? String,
                   let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                   throw VersionError.invalidBundleInfo
               }
               let data = try Data(contentsOf: url)
               guard let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] else {
                   throw VersionError.invalidResponse
               }
               if let result = (json["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String {
                   
                   
                   return version != currentVersion
               }
               throw VersionError.invalidResponse
           }
    
    
    
    class func getDateFromTimestamp(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,YYYY"
        let dateString1: String = dateFormatter.string(from: date)
        
        return dateString1
        
 
    }
    
    class func getBeforfromCurrentDate(_ date: Date) -> String {
        
        let numericDates:Bool = true
        let calendar = Calendar.current
        let now  = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            }
//            else {
//                return "Last year"
//            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            }
//            else {
//                return "Last month"
//            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            }
//            else {
//                return "Last week"
//            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            }
//            else {
//                return "Yesterday"
//            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            }
//            else {
//                return "An hour ago"
//            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            }
//            else {
//                return "A minute ago"
//            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
    // MARK: - Selector Methods
    @objc func leftBarButtonAction(_ sender : UIButton) {
    }
    
    @objc func rightBarButtonAction(_ sender : UIButton) {
    }
  
    
    
}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

