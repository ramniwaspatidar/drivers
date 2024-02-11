
import Foundation

let kForgotlblText = NSLocalizedString("Forgot Password? Reset", comment: "")
let kSiginuplblText = NSLocalizedString("New to ReEnergy? Register Now", comment: "")
let kOTPTxt = NSLocalizedString("Didn’t Receive OTP ? Resend", comment: "")
let kSigninlblText = NSLocalizedString("Already have an account? Login", comment: "")
let TCService = NSLocalizedString("terms & condition.", comment: "")
let TCPolicy = NSLocalizedString("privacy policy", comment: "")

let kTC = NSLocalizedString("I agree with app terms & condition.", comment: "")


let kSignUp = NSLocalizedString("Sign Up", comment: "")
let kSignin = NSLocalizedString(" Login", comment: "")
let kRegisterNow = NSLocalizedString("Register Now", comment: "")
let kMyProfile = NSLocalizedString("My Profile", comment: "")
let kNotifications = NSLocalizedString("Notifications", comment: "")
let kPayments = NSLocalizedString("Payments", comment: "")
let kHelpCenter = NSLocalizedString("Help Center", comment: "")
let kPrivacyPolicy = NSLocalizedString("Privacy and Policy", comment: "")
let kLanguage = NSLocalizedString("Change Language", comment: "")
let kModifyProfile  = NSLocalizedString("Modify Profile", comment: "")

let kRecommendFacilities = NSLocalizedString("Recommend Facilities", comment: "")
let kInvideFriends = NSLocalizedString("Invite Friends", comment: "")
let kChangeProfile = NSLocalizedString("Change Profile", comment: "")
let kNearBy = NSLocalizedString("Near Me   ", comment: "")
let kFavourite = NSLocalizedString("Favourite   ", comment: "")


let kLogout = NSLocalizedString("Sign out", comment: "")
let kLogoutMSG = NSLocalizedString("Are you sure you want to sign out?", comment: "")
let kYes = NSLocalizedString("YES", comment: "")
let kNo = NSLocalizedString("NO", comment: "")

let kExplore = NSLocalizedString("Explore", comment: "")
let kStudios = NSLocalizedString("Studios", comment: "")
let kOnDemand = NSLocalizedString("On Demand", comment: "")
let kLiveStream = NSLocalizedString("Live Stream", comment: "")
let kProfile = NSLocalizedString("Profile", comment: "")

let kupdateEmail = NSLocalizedString("Update Email", comment: "")
let kupdatePassword = NSLocalizedString("Update Password", comment: "")
let kServices = NSLocalizedString("Services", comment: "")
let kFacilities = NSLocalizedString("Facilities", comment: "")
let kCategory = NSLocalizedString("Category", comment: "")
let kChangePassword = NSLocalizedString("Change Password", comment: "")

let countryCode = "+1"






// HextColorCode
let korange = "#FEA428"
let kgray = "#999A9C"
let kred = "#E31D7C"
let kgreen = "#21D729"
let kwhite = "#FFFFFF"
let kLightGray = "#666C78"
let kMediumLightGray = "#F7F8F9"
let kDarkBlue = "#0D82FF"
let kBlue = "#00F2EA"
let kLightBGGray = "#F4F4F4"
let kAlertBG = "#3A3A3C"
let kAlertBlue = "#007AFF"
let kAlertGreen = "#1F7D0E"
let kAlertRed = "#B22D20"




// Mark Alert
let kOk = "Ok"
let kCancel = "Cancel"
let kError = ""
let kstatus = "status"
let kmessage = "message"


let kEmail = "Email"
let kIsSocialLogin = "SocialLogin"
let kSocialId = "SocialId"
let kName = "Name"



// MARK : FAv

let kFavId = "fav_id"
let kUserId = "user_id"
let kStudioId = "studio_id"
let kIsFav = "is_fav"
let kPass_id = "pass_id"
let kRefilled_pass_id = "refilled_pass_id"
let kcustomer_email_id = "customer_email_id"
let klive_stream_video_id = "live_stream_video_id"
let kvideo_time_slot_id = "video_time_slot_id"


// Signin
let krestaurant_id = "restaurant_id"
let kstudio_name = "studio_name"


// signup

let kidtoken = "idtoken"
let kphone_no = "phone_no"
let kdial_code = "dial_code"
let kplatform = "platform"
let kios = "ios"
let kusername = "username"

let kpage_size = "page_size"
let kcurrent_page = "current_page"
let ksearch_date = "search_date"

// MAP
let kLatitude = "latitude"
let kLongitude = "longitude"
let kCity = "city_name"
let kAcceptLanguage = "Accept-Language"



//FONTS

let kFontTextRegular  = "HelveticaNeue-Regular"
let kFontTextBold  = "HelveticaNeue-Bold"
let kFontTextSemibold = "HelveticaNeue-Semibold"
let kFontTextLight  = "HelveticaNeue-Light"
let kFontTextMedium  = "HelveticaNeue-Medium"


// Passes Details

let kcategory_id = "category_id"
let kstudio_type_id = "studio_type_id"
let kpass_type_id = "pass_type_id"



// Font Size
enum AppFont : Float {
    case size8 = 8
    case size9 = 9
    case size10 = 10
    case size11 = 11
    case size12 = 12
    case size13 = 13
    case size14 = 14
    case size15 = 15
    case size16 = 16
    case size17 = 17
    case size18 = 18
    case size19 = 19
    case size20 = 20
    case size21 = 21
    case size22 = 22
    case size23 = 23
    case size24 = 24
    
}

enum PassTypeEnum : Int
  {
     case fitness = 1
     case wellness = 2
     case healthAndBeauty = 3
     case giftCardFitness = 4
     case giftCardCoinsWellness = 5
     case giftCardCoinsHealthAndBeauty = 6
     case refillCoinsHealthAndBeauty = 7
     case refillCoinsWellness = 8
     case giftCardStreaming = 9
     case onDemand = 10
     case liveStreaming = 11
     case onDemandAndLiveStreaming = 12
     case  wellnessOrHealthAndBeauty = 13
     case refillCoinsWellnessOrHealthAndBeauty = 14
  }

enum LanguageText : String {
    case email =  "Email"
    case password = "Password"
    case confirmPassword = "Confirm Password"
    case enterPassword = "Enter password"
    case enterConfirmPassword = "Enter confirm password"
    case samePassword = "Password & Confirm password should be same"
    case emailEnter =  "Enter E-Mail"
    case validEmail = "Enter valid E-Mail"
    case passwordLength = "Password should be minimum 6 characters and at least 1 Alphabet and 1 Number"
    case passwordLengthMessageForSignIn = "Password should be minimum 6 characters"
    case Login = "Login"
    case userName = "Enter username"
    case firstName = "First Name"
    case name = "Enter name"
    case lastName = "Last Name"
    case oldPassword = "Enter old password"
    case newPassword = "Enter new password"
    case confirmEmail = "Confirm Email"
    case passName = "pass name"
    case passValid = "pass validity"
    case serviceTaken = "service taken"
    case coinstTaken = "coins taken"
    case dateOfService = "date of service"
    case number =  "Enter mobile number"
    case emmail = "Enter email"
    case username = "username here with @-_.1"
    case dob = "Enter date of birth"
    case gender = "Enter gender"
    case bio = "Enter description"
    case countryCode = "Please choose country code"
    case inValideNumber = "Please enter valid mobile number"
    case invitationCode = "Enter invitation code"
    case vehicalNumber = "Enter vehical number"
    case entermobilenumber = "Please enter mobile number"
    case newPasswordMessage = "New Password should be minimum 6 characters and at least 1 Alphabet and 1 Number"



}


enum FromViewType : Int{
    case tabbar = 1
    case profile
    case menu
    case notAvailable
}
