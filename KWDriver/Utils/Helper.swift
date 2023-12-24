
import Foundation
import UIKit



struct ScreenSize {
    static  let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
}

struct RootViewController {
    static let controller = (UIApplication.shared.delegate as? AppDelegate)!.window!.rootViewController
}



enum APIError {
    case HTTPError(statusCode :Int)
    case ServerError(message :String)
    
    var description : String {
        switch self {
        case .HTTPError(let statusCode):
            return "\(statusCode)"
            
        case .ServerError(let message):
            return message
        }
    }
}

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
