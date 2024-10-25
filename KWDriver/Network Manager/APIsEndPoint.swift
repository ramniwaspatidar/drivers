
import Foundation

public enum APIsEndPoints: String {
    case ksignupUser = "drivers"
    case kupdateLocation = "drivers/updatelocation"
    case driverStart = "drivers/start"
    case driverEnd = "drivers/end"
    case userProfile = "drivers/me?getNumberOfJob=true"
    case requestList = "drivers/requests/list"
    case kGetRequestData = "drivers/requests/"
    case kAcceptJob = "requests/acceptV2/"
    case kDecline =  "requests/decline/"
    case kArrived = "requests/arrived/"
    case kNoShow = "requests/noshow/"
    case kcompleterequest  = "requests/completerequest/"
    case kGetAvailableJoobs = "drivers/pendingrequests/list"
    case kUploadImage = "drivers/pre-signed-url?count=1"
    case kVerifyCode = "drivers/verifyCode"
    case kCodeRequest = "drivers/requestCode"
    case kArrivedV2 = "requests/arrivedV2/"
    case kGetAddresses = "driver/addresses"
    case kcancelrequest  = "requests/cancel-by-driver/"
    case khandoverrequest  = "requests/handover-request/"
    case kcancelhandoverrequest  = "requests/cancel-handover-request/"
    case kconfirmhandoverrequest  = "requests/confirm-handover-request/"
}
