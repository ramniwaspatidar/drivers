
import Foundation

public enum APIsEndPoints: String {
    case ksignupUser = "drivers"
    case kupdateLocation = "drivers/updatelocation"
    case driverStart = "drivers/start"
    case driverEnd = "drivers/end"
    case userProfile = "drivers/me"
    case requestList = "drivers/requests/list"
    case kGetRequestData = "drivers/requests/"
    case kAcceptJob = "requests/accept/"
    case kDecline =  "requests/decline/"
    case kArrived = "requests/arrived/"

    
}
