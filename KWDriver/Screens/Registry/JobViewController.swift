
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
    @IBOutlet weak var requestIdLabel: UILabel!
    
    @IBOutlet weak var serviceTypeLable: UILabel!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var mapBGView: UIView!
    @IBOutlet weak var callWidth: NSLayoutConstraint!
    @IBOutlet weak var callButton: UIButton!
    
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var codeAnimationView: UIView!
    
    @IBOutlet weak var customerButton: UIButton!
    var requestID: String = ""
    
    var timer: Timer?
    
    var viewModel : LocationViewModel = {
        let model = LocationViewModel()
        return model
    }()
    
    var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerButton.layer.borderWidth = 1;
        customerButton.layer.borderColor = hexStringToUIColor("F7D63D").cgColor
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
    
    func getRequestDetails(_ loading : Bool = false){
        viewModel.getRequestData(APIsEndPoints.kGetRequestData.rawValue + requestID, loading) { [self] response, code in
            self.viewModel.dictRequestData = response
            if((response.driverId == nil || CurrentUserInfo.userId == response.driverId) && response.requestId != nil){
                if(loading){
                    self.jobView.isHidden = false
                }
                self.updateUserData()
                
                if( response.driverArrived == true && response.confirmArrival == false){
                    self.mapView.isHidden = true
                    self.codeView.isHidden = false
                    self.setOPTCode()
                }
                else{
                    self.mapView.isHidden = false
                    self.codeView.isHidden = true
                }
                
                if(response.isRunning){
                    self.timer?.invalidate()
                    self.timer = nil
                    self.startTimer()
                }
                else{
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
            else{
                self.navigationController?.popViewController(animated: false)
                Alert(title: "Error", message: "Request not found", vc: self)
            }
        }
    }
    
    
    func setOPTCode(){
        let str  : String = "\(viewModel.dictRequestData?.arrivalCode ?? "")"
        
        let tempCodeArray = Array(str)
        
        if(tempCodeArray.count > 3){
            lbl1.text = "\(tempCodeArray[0])"
            lbl2.text = "\(tempCodeArray[1])"
            lbl3.text = "\(tempCodeArray[2])"
            lbl4.text = "\(tempCodeArray[3])"
        }
    }
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { _ in
            self.getRequestDetails()
        })
    }
    
    func updateUserData(){
        customerName.text = viewModel.dictRequestData?.name
        customerLocation.text = "\(viewModel.dictRequestData?.address ?? ""), \(viewModel.dictRequestData?.city ?? ""), \(viewModel.dictRequestData?.state ?? ""), \(viewModel.dictRequestData?.country ?? "")"
        
        let currentUserLat = NSString(string: CurrentUserInfo.latitude ?? "0")
        let currentUserLng = NSString(string: CurrentUserInfo.longitude ?? "0")
        
        requestIdLabel.text = "Request Id : \(viewModel.dictRequestData?.reqDispId ?? "")"
        serviceTypeLable.text = "Service : \(viewModel.dictRequestData?.typeOfService ?? "")"
        
        driverName.text = CurrentUserInfo.userName
        viewModel.getAddressFromLatLon(latitude: currentUserLat.doubleValue, withLongitude: currentUserLng.doubleValue){ address in
            self.driverLocation.text = address
        }
        
        let lat = viewModel.dictRequestData?.latitude ?? 0
        let lng = viewModel.dictRequestData?.longitude ?? 0
        
        mapView.delegate = self
        
        var jobDeclined = false
        
        if((viewModel.dictRequestData?.declineDrivers?.count ?? 0 > 0)){
            let drivers = viewModel.dictRequestData?.declineDrivers?.filter({ item  in
                item.driverId == CurrentUserInfo.userId
            })
            
            if(drivers!.count > 0){
                jobDeclined = true
                jobButton.setTitle("DECLINED", for: .normal)
                jobButton.isUserInteractionEnabled = false
                diclineButton.isHidden = true
                jobButton.backgroundColor = .clear
                
                jobButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
                jobButton.setTitleColor(.red, for: .normal)
            }
        }
    
        if (viewModel.dictRequestData?.isRunning == true){
            callButton.isHidden = false
            if(CurrentUserInfo.latitude != nil && CurrentUserInfo.longitude != nil){
                drawPolyline(lat,lng)
            }
            mapView.showsUserLocation = true
        }
        else{
            callButton.isHidden = true
            
            if(viewModel.dictRequestData?.accepted == false && viewModel.dictRequestData?.done == false && jobDeclined == false){
                if(CurrentUserInfo.latitude != nil && CurrentUserInfo.longitude != nil){
                    drawPolyline(lat,lng)
                }
                mapView.showsUserLocation = true
            }else{
                let sourceLat = viewModel.dictRequestData?.acceptedLoc?.lat ?? 0
                let sourceLng = viewModel.dictRequestData?.acceptedLoc?.lng ?? 0
                drawPoint(sourceLat,sourceLng, lat, lng )
                mapView.showsUserLocation = false
                self.distanceBW.text = ""
            }
        }
        
        if(viewModel.dictRequestData?.confirmArrival == true && viewModel.dictRequestData?.done == false){
            jobButton.setTitle("COMPLETE JOB", for: .normal)
            jobButton.setTitleColor(.black, for: .normal)
            jobButton.isHidden = false
            jobButton.backgroundColor = hexStringToUIColor("F7D63D")
            diclineButton.isHidden = true
        }
        else if(viewModel.dictRequestData?.done == false && viewModel.dictRequestData?.driverArrived == true){
            diclineButton.isHidden = true
            jobButton.isHidden = true
        }
        else if(viewModel.dictRequestData?.cancelled == true || viewModel.dictRequestData?.markNoShow == true){
            if((viewModel.dictRequestData?.cancelled) == true){
                jobButton.setTitle("Cancelled", for: .normal)
                jobButton.setTitleColor(.red, for: .normal)
                diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.cancelledDate ?? 0.0), for: .normal)
            }
            else if ((viewModel.dictRequestData?.markNoShow) == true){
                jobButton.setTitle("Customer Not Found", for: .normal)
                jobButton.setTitleColor(.red, for: .normal)
                diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.requestDate ?? 0.0), for: .normal)
            }
            jobButton.backgroundColor = .clear
            jobButton.isUserInteractionEnabled = false
            jobButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
            jobButton.backgroundColor = .clear
            
            diclineButton.isUserInteractionEnabled = false
            diclineButton.setTitleColor(hexStringToUIColor("#DDDBD4"), for: .normal)
            diclineButton.backgroundColor = .clear
            
            distanceBW.isHidden = true
            diclineButton.isHidden = false
            
        }
        else  if(viewModel.dictRequestData?.isPending == false && viewModel.dictRequestData?.done == true){
            jobButton.setTitle("COMPLETED", for: .normal)
            jobButton.backgroundColor = .clear
            jobButton.setTitleColor(hexStringToUIColor("36D91B"), for: .normal)
            jobButton.isUserInteractionEnabled = false
            jobButton.layer.borderWidth = 0
            
            distanceBW.isHidden = true
            
            diclineButton.isHidden = false
            diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.requestCompletedDate ?? 0.0), for: .normal)
            diclineButton.isUserInteractionEnabled = false
            
        }
        else   if(viewModel.dictRequestData?.confirmArrival == true ){
            jobButton.setTitle("Arrived", for: .normal)
            jobButton.setTitleColor(.yellow, for: .normal)
            diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.confrimArrivalDate ?? 0.0), for: .normal)
            
            jobButton.backgroundColor = .clear
            jobButton.isUserInteractionEnabled = false
            jobButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
            jobButton.backgroundColor = .clear
            
            diclineButton.isUserInteractionEnabled = false
            diclineButton.setTitleColor(hexStringToUIColor("#DDDBD4"), for: .normal)
            diclineButton.backgroundColor = .clear
            
            distanceBW.isHidden = true
            diclineButton.isHidden = false
            
        }
        else if(viewModel.dictRequestData?.accepted ?? false){
            jobButton.setTitle("ARRIVED", for: .normal)
            jobButton.backgroundColor = hexStringToUIColor("F7D63D")
            diclineButton.setTitle("Track On Map", for: .normal)
        }
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
        if(self.viewModel.dictRequestData?.isRunning == true){
            guard let url = URL(string: "telprompt://\(self.viewModel.dictRequestData?.phoneNumber ?? "")"),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }else{
            Alert(title: "Error", message: "Waiting for acceptance or job is completed", vc: self)
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
    
    func drawPoint(_ sourceLat : Double, _ sourceLng : Double,_ destLat : Double, _ destLng : Double ) {
        let destinationLocation = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)
        let sourceLocation = CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLng)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        if(sourceLocation.latitude != 0 && sourceLocation.longitude != 0){
            let startAnnotation = CustomAnnotation(
                coordinate: sourceLocation,
                title: "",
                subtitle: "",
                markerTintColor: .blue,
                glyphText: nil,
                image: UIImage(named: "truck_black")
            )
            self.mapView.addAnnotation(startAnnotation)
            
            // Create MKMapPoint for each coordinate
            let point1 = MKMapPoint(destinationLocation)
            let point2 = MKMapPoint(sourceLocation)
            
            // Create MKMapRect that contains both points
            let rect = MKMapRect(x: min(point1.x, point2.x), y: min(point1.y, point2.y), width: abs(point1.x - point2.x), height: abs(point1.y - point2.y))
            
            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: 30, right: 20), animated: false)
        }
        else{
            //Show only 25KM region
            let region = MKCoordinateRegion(center: destinationLocation, latitudinalMeters: 10000, longitudinalMeters: 10000)
            // Set the map's visible region to the calculated region
            mapView.setRegion(region, animated: true)
        }
        
        
        let endAnnotation = CustomAnnotation(
            coordinate: destinationLocation,
            title: "",
            subtitle: "",
            markerTintColor: .blue,
            glyphText: nil,
            image: UIImage(named: "car")
        )
        self.mapView.addAnnotation(endAnnotation)
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
        
        if(viewModel.dictRequestData?.confirmArrival == true && viewModel.dictRequestData?.done == false){
            AlertWithAction(title:"Job Completed", message: "Are you sure that you have completed the job.", ["Completed","No"], vc: self, kAlertGreen) { [self] action in
                if(action == 1){
                    self.jobRequestType(APIsEndPoints.kcompleterequest.rawValue)
                }
            }
        }
        else if(viewModel.dictRequestData?.accepted ?? false){ // code for arrived action
            AlertWithAction(title:"Arrived?", message: "Are you sure that you arrived at customer address?", ["Yes, Arrived","No"], vc: self, kAlertGreen) { [self] action in
                if(action == 1){
                    self.jobRequestType(APIsEndPoints.kArrived.rawValue)
                }
            }
            
        }else{ // accept job
            AlertWithAction(title:"Accept Job", message: "Are you sure to accept this job?", ["Yes, Accept","No"], vc: self, kAlertGreen) { [self] action in
                if(action == 1){
                    self.jobRequestType(APIsEndPoints.kAcceptJob.rawValue,false)
                }
            }
        }
    }
    
    func jobRequestType(_ type : String,_ loading : Bool = true){
        
        if(CurrentUserInfo.latitude == nil){
            Alert(title: kError, message: "Your location service are not running, you must need to run your location service to take any action", vc: RootViewController.controller!)
            return
        }
        else if(CurrentUserInfo.latitude == "0"){
            Alert(title: kError, message: "Your location service are not running, you must need to run your location service to take any action", vc: RootViewController.controller!)
            return
        }
        
        var param = [String : Any]()
        param["latitude"] = Double(CurrentUserInfo.latitude ?? "0")
        param["longitude"] = Double(CurrentUserInfo.longitude ?? "0")
        
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
            
            AlertWithAction(title:"Decline Job", message: "Are you sure to decline this job?", ["Yes, Decline","No"], vc: self, kAlertRed) { [self] action in
                if(action == 1){
                    jobRequestType(APIsEndPoints.kDecline.rawValue)
                }
            }
        }
    }
    
    @IBAction func markNoShow(_ sender: Any) {
        
        AlertWithAction(title:"Customer Not Found", message: "Are you sure that you arrived at customer address and you didn’t found him?", ["Not Found","No"], vc: self, kAlertRed) { [self] action in
            if(action == 1){
                self.jobRequestType(APIsEndPoints.kNoShow.rawValue)
            }
        }
    }
    
    
}

