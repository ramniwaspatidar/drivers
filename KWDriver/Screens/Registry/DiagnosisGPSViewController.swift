//
//  DiagnosisGPSViewController.swift
//  KWDriver
//
//  Created by Lavanya Patidar on 20/03/24.
//

import UIKit
import MapKit

class DiagnosisGPSViewController: BaseViewController,Storyboarded , CLLocationManagerDelegate {
    
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    var coordinator: MainCoordinator?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var previousAnnotation: MKPointAnnotation?
    var appDelegate : AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        if((self.navigationController?.viewControllers.count)! >= 2){
            setNavWithOutView(.back)
        }
        else{
            setNavWithOutView(.menu)
        }
        setupLocationManager()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLocationManager()
    }
    
    func appendLogMessage(_ message: String) {
        txtView.text += "\(message)\n"
        let bottom = NSMakeRange(txtView.text.count - 1, 1)
        txtView.scrollRangeToVisible(bottom)
    }
    
    func stopLocationManager(){
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        currentLocation = nil
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        if(CurrentUserInfo.dutyStarted  == true){
            self.appDelegate?.setupLocationManager()
        }
    }
    
    @IBAction func restartGPS_Clicked(_ sender: Any) {
        if(locationManager != nil){
            stopLocationManager()
        }
        
        setupLocationManager()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            appendLogMessage("Location access denied. Please enable location services in your device settings.")
            locationManager?.stopUpdatingLocation()
            locationManager = nil
            let alert = UIAlertController(title: "Allow Location Access", message: "Driver App needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
            // Button to Open Settings
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case .authorizedWhenInUse,.authorizedAlways:
            appendLogMessage("Location access granted. Waiting for location updates...")
            locationManager?.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        if let annotation = previousAnnotation {
            mapView.removeAnnotation(annotation)
        }
        
        // Display current location on map
        if let location = currentLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Current Location"
            mapView.addAnnotation(annotation)
            mapView.showAnnotations([annotation], animated: true)
            previousAnnotation = annotation
            
            // Print current location
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: location.timestamp)
            let latitude = String(format: "%.6f", location.coordinate.latitude)
            let longitude = String(format: "%.6f", location.coordinate.longitude)
            
            
            appendLogMessage("Location Updated at \(dateString): Lat \(latitude), Lon \(longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
        appendLogMessage("Failed to retrieve location. Please try again later. \(error.localizedDescription)")
        print("locationManager didFailWithError: \(error.localizedDescription)")
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
