
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
    
    @IBOutlet weak var animationView: UIView!
    var requestID: String = ""
    
    var timer: Timer?
    
    var viewModel : LocationViewModel = {
        let model = LocationViewModel()
        return model
    }()
    
    var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavWithOutView(ButtonType.back)
        //        self.getRequestDetails(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        self.getRequestDetails(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func getRequestDetails(_ loading : Bool = false){// 71afc9e0-43bd-4ff9-b428-2f237bb883dd
        viewModel.getRequestData(APIsEndPoints.kGetRequestData.rawValue + requestID, loading) { [self] response, code in
            self.viewModel.dictRequestData = response
            
            if((response.driverId == nil || CurrentUserInfo.userId == response.driverId) && response.requestId != nil){
                if(loading){
                    self.jobView.isHidden = false
                }
                self.updateUserData()
                
                if((response.confirmArrival == false && response.markNoShow == false && response.cancelled == false) && response.driverArrived == true && loading == true){
                    coordinator?.goToOTP(viewModel.dictRequestData!)
                }
                
                
                let runTimer = (response.confirmArrival == true || response.markNoShow == true || response.cancelled == true)
                if(!runTimer){
                    self.timer?.invalidate()
                    self.timer = nil
                    self.startTimer()
                }
            }
            else{
                self.navigationController?.popViewController(animated: false)
                Alert(title: "Error", message: "Request not found", vc: self)
            }
        }
    }
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
            self.getRequestDetails()
        })
    }
    
    func updateUserData(){
        customerName.text = viewModel.dictRequestData?.name
        customerLocation.text = "\(viewModel.dictRequestData?.address ?? ""), \(viewModel.dictRequestData?.city ?? ""), \(viewModel.dictRequestData?.state ?? ""), \(viewModel.dictRequestData?.country ?? "")"
        
        let currentUserLat = NSString(string: CurrentUserInfo.latitude ?? "0")
        let currentUserLng = NSString(string: CurrentUserInfo.longitude ?? "0")
        
        
        driverName.text = CurrentUserInfo.userName
        
        viewModel.getAddressFromLatLon(latitude: currentUserLat.doubleValue, withLongitude: currentUserLng.doubleValue){ address in
            self.driverLocation.text = address
        }
        
        
        let lat = viewModel.dictRequestData?.latitude ?? 0
        let lng = viewModel.dictRequestData?.longitude ?? 0
        
        
        mapView.delegate = self
        
        if(CurrentUserInfo.latitude != nil && CurrentUserInfo.longitude != nil){
            drawPolyline(lat,lng)
        }
        
        if((viewModel.dictRequestData?.declineDrivers?.count ?? 0 > 0)){
            jobButton.setTitle("DECLINED", for: .normal)
            jobButton.isUserInteractionEnabled = false
            diclineButton.isHidden = true
            jobButton.backgroundColor = .red
        }
        else if(viewModel.dictRequestData?.confirmArrival == true || viewModel.dictRequestData?.cancelled == true || viewModel.dictRequestData?.markNoShow == true){
            
            
            if((viewModel.dictRequestData?.cancelled) == true){
                jobButton.setTitle("Cancelled", for: .normal)
                jobButton.setTitleColor(.red, for: .normal)
                
            }
            
            else if ((viewModel.dictRequestData?.markNoShow) == true){
                jobButton.setTitle("Customer Not Found", for: .normal)
                jobButton.setTitleColor(.red, for: .normal)
            }
            else if ((viewModel.dictRequestData?.confirmArrival) == true){
                jobButton.setTitle("Completed", for: .normal)
                jobButton.setTitleColor(.green, for: .normal)
            }
            else if ((viewModel.dictRequestData?.driverArrived) == true){
                jobButton.setTitle("Arrived", for: .normal)
                jobButton.setTitleColor(.yellow, for: .normal)
            }
            
            jobButton.backgroundColor = .clear
            jobButton.isUserInteractionEnabled = false
            jobButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
            
            
            diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.confrimArrivalDate ?? 0.0), for: .normal)
            diclineButton.isUserInteractionEnabled = false
            diclineButton.setTitleColor(hexStringToUIColor("#DDDBD4"), for: .normal)
            diclineButton.backgroundColor = .clear
            
            distanceBW.isHidden = true
            diclineButton.isHidden = true
            
        }
        
        else if(viewModel.dictRequestData?.accepted ?? false){
            jobButton.setTitle("ARRIVED", for: .normal)
            jobButton.backgroundColor = hexStringToUIColor("F7D63D")
            diclineButton.setTitle("Track On Map", for: .normal)
        }
    }
    
    func openAppleMap(_ lat : Double, _ lng : Double){
        let destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = "Destination"
        
        // You can also specify options for the navigation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        destinationMapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func drawPolyline(_ lat : Double, _ lng : Double) {
        let destinationLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let sourceLocation = CLLocationCoordinate2D(latitude: Double(CurrentUserInfo.latitude) ?? 0, longitude:  Double(CurrentUserInfo.longitude) ?? 0)
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
            
            let expectedTravelTime = route.expectedTravelTime
            
            let convertedTime = self.convertTimeIntervalToHoursMinutes(seconds: expectedTravelTime)
            
            let distance = String(format: "%.2f", (route.distance * 0.000621371))
            self.distanceBW.text = "\(distance) miles, \(String(format:"%02d",convertedTime.hours)):\(String(format:"%02d",convertedTime.minutes)) minutes"
            
            // Clear existing overlays and annotations
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20), animated: true)
            
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
    
    func convertTimeIntervalToHoursMinutes(seconds: TimeInterval) -> (hours: Int, minutes: Int) {
        
        var minutes = Int(seconds / 60) % 60
        let hours = Int(seconds / 3600)
        if(minutes <= 1 && hours == 0){
            minutes = 2
        }
        return (hours, minutes)
    }
    
    @IBAction func jobButtonAction(_ sender: Any) {
        if(viewModel.dictRequestData?.accepted ?? false){ // code for arrived action
            self.jobRequestType(APIsEndPoints.kArrived.rawValue)
            
        }else{ // accept job
            self.jobRequestType(APIsEndPoints.kAcceptJob.rawValue,false)
        }
    }
    
    func updateCurrentDriveLocation (){
        var param = [String : Any]()
        
        let lat =  viewModel.dictRequestData?.latitude ?? 0
        let lng = viewModel.dictRequestData?.longitude ?? 0
        
        param["latitude"] = lat
        param["longitude"] = lng
        
        self.viewModel.updateDriveLocation(APIsEndPoints.kupdateLocation.rawValue, param) { [weak self](result,statusCode)in
            if(statusCode == 0){
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    func jobRequestType(_ type : String,_ loading : Bool = true){
        var param = [String : String]()
        
        
        if(type == APIsEndPoints.kArrived.rawValue){
            param["latitude"] = CurrentUserInfo.latitude
            param["longitude"] = CurrentUserInfo.longitude
        }
        
        animationView.isHidden = false
        jobView.isHidden = true
        
        self.viewModel.acceptJob("\(type)\(self.viewModel.dictRequestData?.requestId ?? "")", param,loading) { [weak self](result,statusCode)in
            
            self?.animationView.isHidden = true
            self?.jobView.isHidden = false
            
            if(statusCode == 0){
                self?.getRequestDetails(true)
            }
        }
    }
    
    @IBAction func declineButtonAction(_ sender: Any) {
        if(viewModel.dictRequestData?.accepted ?? false){ // code for track on map
            let lat = viewModel.dictRequestData?.latitude ?? 0
            let lng = viewModel.dictRequestData?.longitude ?? 0
            self.openAppleMap(lat, lng)
        }else{ // decline job
            jobRequestType(APIsEndPoints.kDecline.rawValue)
        }
    }
    
}

