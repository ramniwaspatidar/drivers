
import Foundation
import UIKit
import SideMenu
import MapKit

class JobViewController: BaseViewController,Storyboarded, MKMapViewDelegate {

    @IBOutlet weak var customerLocation: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var driverLocation: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var distanceBW: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var jobButton: UIButton!
    @IBOutlet weak var diclineButton: UIButton!


    
    var viewModel : LocationViewModel = {
        let model = LocationViewModel()
        return model
    }()
    
    var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavWithOutView(ButtonType.menu)

        mapView.delegate = self
        drawPolyline()


    }
    func drawPolyline() {
           let sourceLocation = CLLocationCoordinate2D(latitude: 22.7533, longitude:75.8937)
           let destinationLocation = CLLocationCoordinate2D(latitude: 22.7785, longitude: 75.8880)
           let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
           let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
           
           let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
           let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
           
           let directionRequest = MKDirections.Request()
           directionRequest.source = sourceMapItem
           directionRequest.destination = destinationMapItem
           directionRequest.transportType = .automobile
           
           let directions = MKDirections(request: directionRequest)
           
           directions.calculate { (response, error) in
               guard let response = response else {
                   if let error = error {
                       print("Error getting directions: \(error.localizedDescription)")
                   }
                   return
               }
               
               let route = response.routes[0]
               
               self.mapView.addOverlay(route.polyline, level: .aboveRoads)
               
               self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
               
                     let startAnnotation = CustomAnnotation(
                         coordinate: sourceLocation,
                         title: "Start",
                         subtitle: "",
                         markerTintColor: .blue,
                         glyphText: nil,
                         image: UIImage(named: "truck_black")
                     )

               self.mapView.addAnnotation(startAnnotation)

   
               let endAnnotation = CustomAnnotation(
                   coordinate: destinationLocation,
                   title: "End",
                   subtitle: "",
                   markerTintColor: .blue,
                   glyphText: nil,
                   image: UIImage(named: "car")
               )
               self.mapView.addAnnotation(endAnnotation)

           }
       }
    
    // MKMapViewDelegate method to render the overlay (polyline) on the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           guard let customAnnotation = annotation as? CustomAnnotation else {
               return nil
           }

           let identifier = "CustomAnnotationView"

           var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView

           if annotationView == nil {
               annotationView = CustomAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
           } else {
               annotationView?.annotation = customAnnotation
           }

           return annotationView
       }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func jobButtonAction(_ sender: Any) {
        jobButton.backgroundColor = hexStringToUIColor("FA2A2A")
        
        self.startJob()
        
    }
    
    
    func updateCurrentDriveLocation (){
        var param = [String : String]()
        
        param["latitude"] = "\(CurrentUserInfo.latitude ?? "0")"
        param["longitude"] = "\(CurrentUserInfo.longitude ?? "0")"
        
        self.viewModel.updateDriveLocation(APIsEndPoints.kupdateLocation.rawValue, param) { [weak self](result,statusCode)in
            if(statusCode == 0){
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    func startJob(){
        var param = [String : String]()
        
        param["latitude"] = "\(CurrentUserInfo.latitude ?? "0")"
        param["longitude"] = "\(CurrentUserInfo.longitude ?? "0")"
        
                
        self.viewModel.strartJob(APIsEndPoints.driverStart.rawValue, param) { [weak self](result,statusCode)in
            if(statusCode == 0){
                DispatchQueue.main.async {
                    self?.updateCurrentDriveLocation()
                }
            }
        }
    }
    
    @IBAction func declineButtonAction(_ sender: Any) {
        coordinator?.goToOTP("")
    }
    
  
    }
    
