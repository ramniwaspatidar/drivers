

import UIKit
import CoreLocation
import SVProgressHUD


class LocationViewController: UIViewController,Storyboarded,locationDelegateProtocol {
    
    
    
    var coordinator: MainCoordinator?
    let locationManager = CLLocationManager()
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var locationView: UIView!
    
    var viewModel : LocationViewModel = {
        let model = LocationViewModel()
        return model
    }()
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationView.isHidden = true
        animationView.isHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        SVProgressHUD.show()
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {

    }
    
    @IBAction func continueButton(_ sender: Any) {
        locationView.isHidden = false
        animationView.isHidden = true
      let  appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.delegate = self
        appDelegate?.setupLocationManager()

    }
    func getUserCurrentLocation() {
        coordinator?.goToHome()
    }

}







