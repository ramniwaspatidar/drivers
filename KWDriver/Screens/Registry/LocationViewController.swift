

import UIKit
import CoreLocation
import SVProgressHUD


class LocationViewController: UIViewController,Storyboarded {
    
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
//        locationView.isHidden = false
//        animationView.isHidden = true
//        
//        locationManager.delegate = self
    }
    
    
}
//extension LocationViewController: CLLocationManagerDelegate {
//    
//    func locationManager(_ manager: CLLocationManager,
//                         didUpdateLocations locations: [CLLocation]) {
//        
//        let userLocation: CLLocation = locations[0] // The first location in the array
//        print("location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
//        locationManager.stopUpdatingLocation()
//        
//        self.getAddressFromLatLon(latitude: "\(userLocation.coordinate.latitude)", withLongitude: "\(userLocation.coordinate.longitude)")
//
//    }
//    
//    func locationManager(_ manager: CLLocationManager,
//                         didFailWithError error: Error) {
////        Alert(title: "Error", message: error.localizedDescription, vc: self)
//        
//    }
//}






