

import Foundation
import UIKit
import SideMenu

class MainCoordinator : Coordinator{
    func start() {
        
    }
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func goToOTP(_ dictRequestData : RequestListModal) {
        let vc = OTPViewController.instantiate()
        vc.coordinator = self
        vc.dictRequestData = dictRequestData
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToMobileNUmber() {
        let vc = SigninViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    func goToLocation() {
        let vc = LocationViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    
    func goToArrivalView() {
        let vc = ArrivalViewControoler.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
   
    
    func goToForgotPassword() {
        let vc = ForgotPasswordViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToSignupView() {
        let vc = SignupViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
  
    
    func goToEmailVerificationView(_ email : String, _ password : String, _ phone : String = "",_ isEmailVerification : Bool = true,_ vechicalID : String = "") {
        let vc = EmailVerificationViewController.instantiate()
        vc.coordinator = self
        vc.password = password
        vc.email = email
        vc.phone = phone
        vc.vehicalID = vechicalID
        vc.isEmailVerification = isEmailVerification
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToProfile(_ userNotExist : Bool = false) {
        let vc = ProfileViewController.instantiate()
        vc.coordinator = self
        vc.viewModel.userNotExist = userNotExist;
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToHome() {
        let vc = HomeViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToJobView(_ requestId : String) {
        let vc = JobViewController.instantiate()
        vc.coordinator = self
        vc.requestID = requestId
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToRequestList() {
        let vc = RequestListViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    
    func gotoChangePassword() {
        let vc = ChangePasswordViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToWebview(type : WebViewType){
        let vc = WKWebViewController.instantiate()
        vc.coordinator = self
        vc.webViewType = type
        navigationController.pushViewController(vc, animated: false)
    }
    
}
