
import Foundation
import UIKit
import SideMenu
import MapKit

class JobViewController: BaseViewController,Storyboarded, MKMapViewDelegate ,AddressChangeDelegate, HandoverAddressChangeDelegate{
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
    @IBOutlet var jobButtonTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lbl5: UILabel!
    @IBOutlet weak var lbl6: UILabel!
    @IBOutlet weak var codeAnimationView: UIView!
    
    @IBOutlet weak var moreButton: UIButton!
    
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
        cancelButton.isHidden = true
        customerButton.layer.borderWidth = 1;
        customerButton.layer.borderColor = hexStringToUIColor("F7D63D").cgColor
        if(self.navigationController?.viewControllers.count ?? 0 > 1){
            self.setNavWithOutView(ButtonType.back)
        }
        else{
            self.setNavWithOutView(ButtonType.menu)
        }
        //        self.getRequestDetails(true)
    }
    
    @IBAction func cancelButton_Clicked(_ sender: Any) {
        AlertWithAction(title:"Job Cancel", message: "Are you sure that you want to cancel this job.", ["Yes, Cancel","No"], vc: self, kAlertRed) { [self] action in
            if(action == 1){
                callAcceptAPI(APIsEndPoints.kcancelrequest.rawValue)
            }
        }
    }
    @IBAction func moreButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Booking Action", message: "", preferredStyle: .actionSheet)
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = hexStringToUIColor("#F4CC9E")
        alertController.view.tintColor = UIColor.black
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let canclebooking = UIAlertAction(title: "Handover to other driver", style: .default) { action in
            AlertWithAction(title:"Handover Booking", message: "Are you sure that you want to Handover Booking?", ["Handover Booking","No"], vc: self,kAlertRed) { [self] action in
                if(action == 1){
                    if(self.viewModel.dictRequestData?.confirmArrival ?? false){
                        self.coordinator?.goToHandoverAddressView(delegate: self)
                    }
                    else{
                        let param = [String : String]()
                        self.viewModel.handoverRequest("\(APIsEndPoints.khandoverrequest.rawValue)\(self.viewModel.dictRequestData?.requestId ?? "")", param,true) { [weak self](result,statusCode)in
                            if(statusCode == 0){
                                self?.updateView(result)
                            }
                        }
                    }
                }
            }
        }
        alertController.addAction(canclebooking)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
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
            
            if(loading){
                self.jobView.isHidden = false
            }
            
            updateView(response)
        }
    }
    
    func updateView(_ request: RequestListModal){
        self.viewModel.dictRequestData = request
        let isReassign = isJobReassign()
        if((request.driverId == nil || CurrentUserInfo.userId == request.driverId) && request.requestId != nil){
            self.updateUserData()
            if( request.driverArrived == true && request.confirmArrival == false && request.markNoShow == false && request.cancelled == false && isReassign == false){
                self.mapView.isHidden = true
                self.codeView.isHidden = false
                self.setOPTCode()
            }
            else{
                self.mapView.isHidden = false
                self.codeView.isHidden = true
            }
            
            if(request.isPending == 1 || request.isPending == 2){
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
            if(isReassign){
                self.updateReassignUserData()
                self.mapView.isHidden = false
                self.codeView.isHidden = true
                if(request.isPending == 1 || request.isPending == 2){
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
                let isConfirmHandoverCase = isJobConfirmHandover()
                if(isConfirmHandoverCase){
                    self.updateUserData()
                    self.mapView.isHidden = false
                    self.codeView.isHidden = true
                    
                    if(request.isPending == 1 || request.isPending == 2){
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
                    if(self.navigationController?.viewControllers.count ?? 0 > 1){
                        self.navigationController?.popViewController(animated: false)
                    }
                    else{
                        coordinator?.goToHome(true)
                    }
                    Alert(title: "Error", message: "Thank you for answering the call. Stay tuned for the next one.", vc: self)
                }
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
    
    func isJobReassign() -> Bool{
        var isReassign = false
        if(viewModel.dictRequestData?.isPending == 2){
            if (viewModel.dictRequestData?.reassignDriverList != nil){
                let drivers = viewModel.dictRequestData?.reassignDriverList?.filter({ item  in
                    item.driverId == CurrentUserInfo.userId
                })
                if(drivers?.count ?? 0 > 0){
                    isReassign = true
                }
            }
            if(viewModel.dictRequestData?.isPendingSubStatus == 1){
                isReassign = true
            }
        }

        return isReassign
    }
    
    func isJobConfirmHandover() -> Bool{
        var isConfirmHandoverCase = false
        if(viewModel.dictRequestData?.isPending == 2){
            if(viewModel.dictRequestData?.confirmHandover ?? false && viewModel.dictRequestData?.reassignHistory != nil){
                if((viewModel.dictRequestData?.reassignHistory?.count ?? 0 > 0)){
                    let requestHistory = viewModel.dictRequestData?.reassignHistory?.filter({ item  in
                        item.reassignRequestId == viewModel.dictRequestData?.reassignRequestId && item.driverId == CurrentUserInfo.userId
                    })
                    if(requestHistory?.count ?? 0 > 0){
                        isConfirmHandoverCase = true
                    }
                }
            }
            
            if(viewModel.dictRequestData?.confirmHandover ?? false && viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                isConfirmHandoverCase = true
            }
        }

        return isConfirmHandoverCase
    }
    
    func updateUserData(){
        
        let isConfirmHandoverCase = isJobConfirmHandover()
        
        moreButton.isHidden = true
        cancelButton.isHidden = true
        jobButtonTrailing.constant = 12
        customerName.text = viewModel.dictRequestData?.name
        
        customerLocation.text = "\(viewModel.dictRequestData?.address ?? ""), \(viewModel.dictRequestData?.address1 ?? ""), \(viewModel.dictRequestData?.city ?? ""), \(viewModel.dictRequestData?.state ?? ""), \(viewModel.dictRequestData?.postalCode ?? ""), \(viewModel.dictRequestData?.landmark ?? "")"
        customerLocation.text = customerLocation.text?.replacingOccurrences(of: ", , ", with: ", ")
        customerLocation.text = customerLocation.text?.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        
        if(self.viewModel.dictRequestData?.destinationAdd != nil){
            customerLocation.text = "\(viewModel.dictRequestData?.destinationAdd?.address ?? ""), \(viewModel.dictRequestData?.destinationAdd?.address1 ?? ""), \(viewModel.dictRequestData?.destinationAdd?.city ?? ""), \(viewModel.dictRequestData?.destinationAdd?.state ?? ""), \(viewModel.dictRequestData?.destinationAdd?.postalCode ?? ""), \(viewModel.dictRequestData?.destinationAdd?.landmark ?? "")"
            customerLocation.text = customerLocation.text?.replacingOccurrences(of: ", , ", with: ", ")
            customerLocation.text = customerLocation.text?.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        }
        
        let currentUserLat = NSString(string: CurrentUserInfo.latitude ?? "0")
        let currentUserLng = NSString(string: CurrentUserInfo.longitude ?? "0")
        
        requestIdLabel.text = "Request Id : \(viewModel.dictRequestData?.reqDispId ?? "")"
        serviceTypeLable.text = "Service : \(viewModel.dictRequestData?.typeOfService ?? "")"
        
        driverName.text = CurrentUserInfo.userName
        if(viewModel.dictRequestData?.isPending == 1){
            viewModel.getAddressFromLatLon(latitude: currentUserLat.doubleValue, withLongitude: currentUserLng.doubleValue){ address in
                self.driverLocation.text = address
            }
        }
        else{
            let sourceLat = viewModel.dictRequestData?.acceptedLoc?.lat ?? 0
            let sourceLng = viewModel.dictRequestData?.acceptedLoc?.lng ?? 0
            viewModel.getAddressFromLatLon(latitude: sourceLat, withLongitude: sourceLng){ address in
                self.driverLocation.text = address
            }
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
                drawPolyline(lat,lng, false)
            }
            mapView.showsUserLocation = true
        }
        else{
            callButton.isHidden = true
            
            if(viewModel.dictRequestData?.accepted == false && viewModel.dictRequestData?.done == false && jobDeclined == false){
                if(viewModel.dictRequestData?.acceptDriverList?.count ?? 0 > 0){
                    let drivers = viewModel.dictRequestData?.acceptDriverList?.filter({ item  in
                        item.driverId == CurrentUserInfo.userId
                    })
                    
                    if(drivers!.count > 0){
                        jobButton.setTitle("PENDING", for: .normal)
                        jobButton.isUserInteractionEnabled = false
                        jobButton.backgroundColor = .clear
                        jobButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
                        jobButton.setTitleColor(hexStringToUIColor(kAlertBlue), for: .normal)
                        diclineButton.isHidden = false
                        diclineButton.backgroundColor = hexStringToUIColor(kAlertRed)
                        diclineButton.setTitleColor(.white, for: .normal)
                        
                    }
                }
                
                if(CurrentUserInfo.latitude != nil && CurrentUserInfo.longitude != nil){
                    drawPolyline(lat,lng, false)
                }
                else{
                    let destinationLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    // Clear existing overlays and annotations
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    // Create a coordinate region with the center coordinate and span
                    let coordinateRegion = MKCoordinateRegion(center: destinationLocation, latitudinalMeters: 30000, longitudinalMeters: 30000)
                    // Set the region on the map view
                    mapView.setRegion(coordinateRegion, animated: true)
                    
                    let endAnnotation = CustomAnnotation(
                        coordinate: destinationLocation,
                        title: "Customer Location",
                        subtitle: "",
                        markerTintColor: .blue,
                        glyphText: nil,
                        image: UIImage(named: "car")
                    )
                    self.mapView.addAnnotation(endAnnotation)
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
            moreButton.isHidden = false
            jobButton.setTitle("COMPLETE JOB", for: .normal)
            jobButton.setTitleColor(.black, for: .normal)
            jobButton.isHidden = false
            jobButton.backgroundColor = hexStringToUIColor("F7D63D")
            diclineButton.isHidden = false
            diclineButton.isUserInteractionEnabled = true
            diclineButton.setTitle("Track On Map", for: .normal)
            diclineButton.backgroundColor = .clear
            diclineButton.setTitleColor(hexStringToUIColor("9CD4FC"), for: .normal)
            //reassigned Job
            if(viewModel.dictRequestData?.isPendingSubStatus == 1 && viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                cancelButton.isHidden = true
                jobButtonTrailing.constant = 12
                jobButton.backgroundColor = .systemRed
                jobButton.setTitle("Cancel Handover request", for: .normal)
                jobButton.setTitleColor(.white, for: .normal)
                moreButton.isHidden = true
            }
            
            if(isConfirmHandoverCase){
                moreButton.isHidden = true
                jobButton.setTitle("CONFIRM HANDOVER", for: .normal)
                if(viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                    if((viewModel.dictRequestData?.reassignHistory?.count ?? 0 > 0)){
                        let requestHistory = viewModel.dictRequestData?.reassignHistory?.filter({ item  in
                            item.reassignRequestId == viewModel.dictRequestData?.reassignRequestId
                        })
                        if(requestHistory?.count ?? 0 > 0){
                            diclineButton.setTitle("Call \(requestHistory?.first?.driverName ?? "")", for: .normal)
                        }
                    }
                    
                }
                else{
                    diclineButton.setTitle("Call \(viewModel.dictRequestData?.driverName ?? "")", for: .normal)
                }
            }
        }
        else if(viewModel.dictRequestData?.done == false && viewModel.dictRequestData?.driverArrived == true){
            moreButton.isHidden = false
            diclineButton.isHidden = true
            jobButton.isHidden = true
            //reassigned Job
            if(viewModel.dictRequestData?.isPendingSubStatus == 1 && viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                cancelButton.isHidden = true
                jobButton.isHidden = false
                jobButtonTrailing.constant = 12
                jobButton.backgroundColor = .systemRed
                jobButton.setTitle("Cancel Handover request", for: .normal)
                jobButton.setTitleColor(.white, for: .normal)
                moreButton.isHidden = true
            }
        }
        else if(viewModel.dictRequestData?.cancelled == true || viewModel.dictRequestData?.markNoShow == true){
            if((viewModel.dictRequestData?.cancelled) == true){
                jobButton.setTitle("Cancelled", for: .normal)
                jobButton.setTitleColor(.red, for: .normal)
                jobButton.backgroundColor = .clear
                jobButton.isHidden = false
                diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.cancelledDate ?? 0.0), for: .normal)
            }
            else if ((viewModel.dictRequestData?.markNoShow) == true){
                jobButton.setTitle("Tow Not Found", for: .normal)
                jobButton.setTitleColor(.red, for: .normal)
                jobButton.isHidden = false
                diclineButton.setTitle(AppUtility.getDateFromTimeEstime(viewModel.dictRequestData?.requestDate ?? 0.0), for: .normal)
            }
            jobButton.backgroundColor = .clear
            jobButton.isUserInteractionEnabled = false
            jobButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
            
            diclineButton.isUserInteractionEnabled = false
            diclineButton.setTitleColor(hexStringToUIColor("#DDDBD4"), for: .normal)
            diclineButton.backgroundColor = .clear
            
            distanceBW.isHidden = true
            diclineButton.isHidden = false
        }
        else  if(viewModel.dictRequestData?.isPending == 5 && viewModel.dictRequestData?.done == true){
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
        else if(viewModel.dictRequestData?.accepted ?? false){
            jobButton.setTitle("ARRIVED", for: .normal)
            jobButton.backgroundColor = hexStringToUIColor("F7D63D")
            jobButton.isUserInteractionEnabled = true
            jobButton.setTitleColor(.black, for: .normal)
            diclineButton.setTitle("Track On Map", for: .normal)
            diclineButton.backgroundColor = .clear
            diclineButton.setTitleColor(hexStringToUIColor("9CD4FC"), for: .normal)
            cancelButton.isHidden = false
            jobButtonTrailing.constant = (ScreenSize.screenWidth/2)-10
            moreButton.isHidden = false
            //reassigned Job
            if(viewModel.dictRequestData?.isPendingSubStatus == 1 && viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                cancelButton.isHidden = true
                jobButtonTrailing.constant = 12
                jobButton.backgroundColor = .systemRed
                jobButton.setTitle("Cancel Handover request", for: .normal)
                jobButton.setTitleColor(.white, for: .normal)
                moreButton.isHidden = true
            }
        }
    }
    
    func updateReassignUserData(){
        moreButton.isHidden = true
        cancelButton.isHidden = true
        jobButtonTrailing.constant = 12
        customerName.text = viewModel.dictRequestData?.name
        
        customerLocation.text = "\(viewModel.dictRequestData?.address ?? ""), \(viewModel.dictRequestData?.address1 ?? ""), \(viewModel.dictRequestData?.city ?? ""), \(viewModel.dictRequestData?.state ?? ""), \(viewModel.dictRequestData?.postalCode ?? ""), \(viewModel.dictRequestData?.landmark ?? "")"
        customerLocation.text = customerLocation.text?.replacingOccurrences(of: ", , ", with: ", ")
        customerLocation.text = customerLocation.text?.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        
        if(self.viewModel.dictRequestData?.destinationAdd != nil){
            customerLocation.text = "\(viewModel.dictRequestData?.destinationAdd?.address ?? ""), \(viewModel.dictRequestData?.destinationAdd?.address1 ?? ""), \(viewModel.dictRequestData?.destinationAdd?.city ?? ""), \(viewModel.dictRequestData?.destinationAdd?.state ?? ""), \(viewModel.dictRequestData?.destinationAdd?.postalCode ?? ""), \(viewModel.dictRequestData?.destinationAdd?.landmark ?? "")"
            customerLocation.text = customerLocation.text?.replacingOccurrences(of: ", , ", with: ", ")
            customerLocation.text = customerLocation.text?.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        }
        
        requestIdLabel.text = "Request Id : \(viewModel.dictRequestData?.reqDispId ?? "")"
        serviceTypeLable.text = "Service : \(viewModel.dictRequestData?.typeOfService ?? "")"
        
        driverName.text = "\(viewModel.dictRequestData?.driverName ?? "")(Old Driver)"
        if(viewModel.dictRequestData?.prevDriverLocation != nil){
            self.driverLocation.text = "\(viewModel.dictRequestData?.prevDriverLocation?.address ?? ""), \(viewModel.dictRequestData?.prevDriverLocation?.city ?? ""), \(viewModel.dictRequestData?.prevDriverLocation?.postalCode ?? ""), \(viewModel.dictRequestData?.prevDriverLocation?.state ?? "")"
        }
        
        
        
        let lat = viewModel.dictRequestData?.latitude ?? 0
        let lng = viewModel.dictRequestData?.longitude ?? 0
        
        
        
        mapView.delegate = self
        
        var jobDeclined = false
        
        if((viewModel.dictRequestData?.declineReassignDrivers?.count ?? 0 > 0)){
            let drivers = viewModel.dictRequestData?.declineReassignDrivers?.filter({ item  in
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
        
        
        callButton.isHidden = true
        
        if(jobDeclined == false){
            if(viewModel.dictRequestData?.reassignAcceptDriverList?.count ?? 0 > 0){
                let drivers = viewModel.dictRequestData?.reassignAcceptDriverList?.filter({ item  in
                    item.driverId == CurrentUserInfo.userId
                })
                
                if(drivers!.count > 0){
                    jobButton.setTitle("PENDING", for: .normal)
                    jobButton.isUserInteractionEnabled = false
                    jobButton.backgroundColor = .clear
                    jobButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
                    jobButton.setTitleColor(hexStringToUIColor(kAlertBlue), for: .normal)
                    diclineButton.isHidden = false
                    diclineButton.backgroundColor = hexStringToUIColor(kAlertRed)
                    diclineButton.setTitleColor(.white, for: .normal)
                }
            }
            
            if(CurrentUserInfo.latitude != nil && CurrentUserInfo.longitude != nil){
                drawPolyline(lat,lng, true)
            }
            else{
                let destinationLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                // Clear existing overlays and annotations
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.removeAnnotations(self.mapView.annotations)
                // Create a coordinate region with the center coordinate and span
                let coordinateRegion = MKCoordinateRegion(center: destinationLocation, latitudinalMeters: 30000, longitudinalMeters: 30000)
                // Set the region on the map view
                mapView.setRegion(coordinateRegion, animated: true)
                
                let endAnnotation = CustomAnnotation(
                    coordinate: destinationLocation,
                    title: "Customer Location",
                    subtitle: "",
                    markerTintColor: .blue,
                    glyphText: nil,
                    image: UIImage(named: "car")
                )
                self.mapView.addAnnotation(endAnnotation)
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
        var destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        if(self.viewModel.dictRequestData?.destinationAdd != nil){
            destinationCoordinate = CLLocationCoordinate2D(latitude: self.viewModel.dictRequestData?.destinationAdd?.latitude ?? 0.0, longitude: self.viewModel.dictRequestData?.destinationAdd?.longitude ?? 0.0)
        }
        
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = "Pickup"
        if(self.viewModel.dictRequestData?.destinationAdd != nil){
            destinationMapItem.name = "Dropoff"
        }
        
        // You can also specify options for the navigation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        destinationMapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func drawPolyline(_ lat : Double, _ lng : Double, _ showReassign: Bool) {
        var isShowReassign = false
        let pickupLocation = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let dropOffLocation = CLLocationCoordinate2D(latitude: self.viewModel.dictRequestData?.destinationAdd?.latitude ?? 0.0, longitude: self.viewModel.dictRequestData?.destinationAdd?.longitude ?? 0.0)
        let prevDrvLocation = CLLocationCoordinate2D(latitude: self.viewModel.dictRequestData?.prevDriverLocation?.latitude ?? 0.0, longitude: self.viewModel.dictRequestData?.prevDriverLocation?.longitude ?? 0.0)
        if(showReassign){
            if(self.viewModel.dictRequestData?.prevDriverLocation != nil && showReassign){
                isShowReassign = true
            }
        }
        
        
        let currentLocation = CLLocationCoordinate2D(latitude: Double(CurrentUserInfo.latitude) ?? 0, longitude:  Double(CurrentUserInfo.longitude) ?? 0)
        let currentPlacemark = MKPlacemark(coordinate: currentLocation, addressDictionary: nil)
        let currentMapItem = MKMapItem(placemark: currentPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = currentMapItem
        if(self.viewModel.dictRequestData?.prevDriverLocation != nil && isShowReassign){
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate:prevDrvLocation , addressDictionary: nil))
        }
        else if(self.viewModel.dictRequestData?.destinationAdd != nil && self.viewModel.dictRequestData?.confirmArrival ?? false){
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate:dropOffLocation , addressDictionary: nil))
        }
        else{
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: pickupLocation, addressDictionary: nil))
        }
        
        
        if(self.viewModel.dictRequestData?.confirmHandover ?? false && self.viewModel.dictRequestData?.driverId == CurrentUserInfo.userId && self.viewModel.dictRequestData?.prevDriverLocation != nil){
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate:prevDrvLocation , addressDictionary: nil))
        }
        
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
            //            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20), animated: true)
            
            var locations = [
                currentLocation,
                pickupLocation
            ]
            
            if(self.viewModel.dictRequestData?.acceptedLoc != nil){
                locations.append(CLLocationCoordinate2D(latitude: self.viewModel.dictRequestData?.acceptedLoc?.lat ?? 0.0, longitude: self.viewModel.dictRequestData?.acceptedLoc?.lng ?? 0.0))
                let startAnnotation = CustomAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: self.viewModel.dictRequestData?.acceptedLoc?.lat ?? 0.0, longitude: self.viewModel.dictRequestData?.acceptedLoc?.lng ?? 0.0),
                    title: "Start",
                    subtitle: "",
                    markerTintColor: .blue,
                    glyphText: nil,
                    image: UIImage(named: "truck_black")
                )
                
                self.mapView.addAnnotation(startAnnotation)
            }
            else{
                let startAnnotation = CustomAnnotation(
                    coordinate: currentLocation,
                    title: "Start",
                    subtitle: "",
                    markerTintColor: .blue,
                    glyphText: nil,
                    image: UIImage(named: "truck_black")
                )
                
                self.mapView.addAnnotation(startAnnotation)
            }
            
            
            
            let endAnnotation = CustomAnnotation(
                coordinate: pickupLocation,
                title: "Pickup",
                subtitle: "",
                markerTintColor: .blue,
                glyphText: nil,
                image: UIImage(named: "car")
            )
            
            self.mapView.addAnnotation(endAnnotation)
            
            if(self.viewModel.dictRequestData?.prevDriverLocation != nil && isShowReassign){
                let dropOffAnnotation = CustomAnnotation(
                    coordinate: prevDrvLocation,
                    title: "\(self.viewModel.dictRequestData?.driverName ?? "") Location",
                    subtitle: "",
                    markerTintColor: .systemGreen,
                    glyphText: nil,
                    image: UIImage(named: "car")
                )
                locations.append(dropOffLocation)
                self.mapView.addAnnotation(dropOffAnnotation)
            }
            
            if(self.viewModel.dictRequestData?.confirmHandover ?? false && self.viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                
                var driverName = "Driver"
                
                let requestHistory = self.viewModel.dictRequestData?.reassignHistory?.filter({ item  in
                    item.reassignRequestId == self.viewModel.dictRequestData?.reassignRequestId
                })
                if(requestHistory?.count ?? 0 > 0){
                    driverName = requestHistory?.first?.driverName ?? "Driver"
                }
                
                let dropOffAnnotation = CustomAnnotation(
                    coordinate: prevDrvLocation,
                    title: "\(driverName ) Location",
                    subtitle: "",
                    markerTintColor: .systemGreen,
                    glyphText: nil,
                    image: UIImage(named: "car")
                )
                locations.append(dropOffLocation)
                self.mapView.addAnnotation(dropOffAnnotation)
            }
            
            if(self.viewModel.dictRequestData?.destinationAdd != nil){
                let dropOffAnnotation = CustomAnnotation(
                    coordinate: dropOffLocation,
                    title: "Dropoff",
                    subtitle: "",
                    markerTintColor: .systemPink,
                    glyphText: nil,
                    image: UIImage(named: "car")
                )
                locations.append(dropOffLocation)
                self.mapView.addAnnotation(dropOffAnnotation)
            }
            
            // Calculate the region that includes all the locations with padding
            var maxLat: CLLocationDegrees = -90
            var maxLon: CLLocationDegrees = -180
            var minLat: CLLocationDegrees = 90
            var minLon: CLLocationDegrees = 180
            
            for location in locations {
                if location.latitude > maxLat {
                    maxLat = location.latitude
                }
                if location.latitude < minLat {
                    minLat = location.latitude
                }
                if location.longitude > maxLon {
                    maxLon = location.longitude
                }
                if location.longitude < minLon {
                    minLon = location.longitude
                }
            }
            
            let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLon - minLon) * 1.3)
            let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2, longitude: (maxLon + minLon) / 2)
            let region = MKCoordinateRegion(center: center, span: span)
            
            // Set the calculated region on the map
            self.mapView.setRegion(region, animated: true)
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
        let isConfirmHandoverCase = isJobConfirmHandover()
        let isReasign = isJobReassign()
        if(isReasign == false){
            if(viewModel.dictRequestData?.confirmArrival == true && viewModel.dictRequestData?.done == false){
                if(isConfirmHandoverCase){
                    AlertWithAction(title:"Confirm Handover", message: "Are you sure to confirm handover for this request?", ["Yes, Complete","No"], vc: self, kAlertRed) { [self] action in
                        if(action == 1){
                            let param = [String : String]()
                            self.viewModel.handoverRequest("\(APIsEndPoints.kconfirmhandoverrequest.rawValue)\(self.viewModel.dictRequestData?.requestId ?? "")", param,true) { [weak self](result,statusCode)in
                                if(statusCode == 0){
                                    self?.updateView(result)
                                }
                            }
                        }
                    }
                }
                else{
                    AlertWithAction(title:"Job Completed", message: "Are you sure that you have completed the job.", ["Completed","No"], vc: self, kAlertGreen) { [self] action in
                        if(action == 1){
                            self.jobRequestType(APIsEndPoints.kcompleterequest.rawValue)
                        }
                    }
                }
            }
            else if(viewModel.dictRequestData?.accepted ?? false){ // code for arrived action
                AlertWithAction(title:"Arrived?", message: "Are you sure that you arrived at customer address?", ["Yes, Arrived","No"], vc: self, kAlertGreen) { [self] action in
                    if(action == 1){
                        //                    self.jobRequestType(APIsEndPoints.kArrived.rawValue)
                        self.coordinator?.goToAddressView(delegate: self)
                    }
                }
                
            }else{ // accept job
                AlertWithAction(title:"Accept Job", message: "Are you sure to accept this job?", ["Yes, Accept","No"], vc: self, kAlertGreen) { [self] action in
                    if(action == 1){
                        self.jobRequestType(APIsEndPoints.kAcceptJob.rawValue)
                    }
                }
            }
        }
        else {
            if(viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                // For Cancel Handover job request
                AlertWithAction(title:"Cancel Handover Request", message: "Are you sure to cancel handover request?", ["Yes, Cancel","No"], vc: self, kAlertRed) { [self] action in
                    if(action == 1){
                        let param = [String : String]()
                        self.viewModel.handoverRequest("\(APIsEndPoints.kcancelhandoverrequest.rawValue)\(self.viewModel.dictRequestData?.requestId ?? "")", param,true) { [weak self](result,statusCode)in
                            if(statusCode == 0){
                                self?.updateView(result)
                            }
                        }
                    }
                }
            }
            else{
                AlertWithAction(title:"Accept Job", message: "Are you sure to accept this job?", ["Yes, Accept","No"], vc: self, kAlertGreen) { [self] action in
                    if(action == 1){
                        self.jobRequestType(APIsEndPoints.kAcceptJob.rawValue)
                    }
                }
            }
        }
        
    }
    
    func addressChangeAction(infoArray: [AddressTypeModel], _ lat: String, _ lng: String) {
        var param = [String : Any]()
        param["address"] =  infoArray[0].value
        param["city"] = infoArray[1].value
        param["state"] = infoArray[2].value
        param["postalCode"] = infoArray[3].value
        param["country"] = infoArray[4].value
        param["latitude"] = Double(lat)
        param["longitude"] =  Double(lng)
        self.jobRequestType(APIsEndPoints.kArrivedV2.rawValue,true,param)
    }
    
    func handoverAddressChangeAction(infoArray: [AddressTypeModel], _ lat: String, _ lng: String) {
        var param = [String : Any]()
        param["address"] =  infoArray[0].value
        param["city"] = infoArray[1].value
        param["state"] = infoArray[2].value
        param["postalCode"] = infoArray[3].value
        param["country"] = infoArray[4].value
        param["latitude"] = Double(lat)
        param["longitude"] =  Double(lng)
        self.viewModel.handoverRequest("\(APIsEndPoints.khandoverrequest.rawValue)\(self.viewModel.dictRequestData?.requestId ?? "")", param,true) { [weak self](result,statusCode)in
            if(statusCode == 0){
                self?.updateView(result)
            }
        }
    }
    
    func jobRequestType(_ type : String,_ loading : Bool = true, _ address : [String : Any] = [String : Any]()){
        if(CurrentUserInfo.latitude == "0" || CurrentUserInfo.latitude == nil){
            AlertWithAction(title:kError, message: "Your location services are not active. You must enable location services to take any action. Would you like to restart your GPS service?", ["Yes","No"], vc: self, kAlertRed) { [self] action in
                if(action == 1){
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let status = CLLocationManager.authorizationStatus()
                    switch status {
                    case .notDetermined:
                        appDelegate?.setupLocationManager()
                    case .restricted, .denied:
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
                        appDelegate?.setupLocationManager()
                        appDelegate?.startGPSTraking()
                        break
                    default:
                        break
                    }
                }
            }
        }
        else{
            callAcceptAPI(type, loading,address)
        }
    }
    
    func callAcceptAPI(_ type : String,_ loading : Bool = true,_ address : [String : Any] = [String : Any]()){
        var param = [String : Any]()
        param["latitude"] = Double(CurrentUserInfo.latitude ?? "0")
        param["longitude"] = Double(CurrentUserInfo.longitude ?? "0")
        param["destinationAdd"] = address
        
        self.viewModel.acceptJob("\(type)\(self.viewModel.dictRequestData?.requestId ?? "")", param,loading) { [weak self](result,statusCode)in
            self?.animationView.isHidden = true
            self?.jobView.isHidden = false
            if(statusCode == 0){
                self?.getRequestDetails(true)
            }
            if(type == APIsEndPoints.kAcceptJob.rawValue && result.driverId == nil){
                Alert(title:"", message: "This Job is Pending Approval. You will be notified with an update.", vc: self!)
            }
            if(type == APIsEndPoints.kcancelrequest.rawValue){
                if(self?.navigationController?.viewControllers.count ?? 0 > 1){
                    self?.navigationController?.popViewController(animated: false)
                }
                else{
                    self?.coordinator?.goToHome(true)
                }
            }
        }
    }
    
    @IBAction func declineButtonAction(_ sender: Any) {
        let isReassigned = isJobReassign()
        let isConfirmHandoverCase = isJobConfirmHandover()
        if(isReassigned){
            AlertWithAction(title:"Decline Job", message: "Are you sure to decline this job?", ["Yes, Decline","No"], vc: self, kAlertRed) { [self] action in
                if(action == 1){
                    jobRequestType(APIsEndPoints.kDecline.rawValue)
                }
            }
        }
        else if(isConfirmHandoverCase){
            //call to driver
            if(viewModel.dictRequestData?.driverId == CurrentUserInfo.userId){
                if((viewModel.dictRequestData?.reassignHistory?.count ?? 0 > 0)){
                    let requestHistory = viewModel.dictRequestData?.reassignHistory?.filter({ item  in
                        item.reassignRequestId == viewModel.dictRequestData?.reassignRequestId
                    })
                    if(requestHistory?.count ?? 0 > 0){
                        guard let url = URL(string: "telprompt://\(requestHistory?.first?.driverPhoneNumber ?? "")"),
                              UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }
            else{
                guard let url = URL(string: "telprompt://\(self.viewModel.dictRequestData?.driverPhoneNumber ?? "")"),
                      UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        else{
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
    }

    @IBAction func markNoShow(_ sender: Any) {
        AlertWithAction(title:"Tow Not Found", message: "Are you sure that you arrived at customer address and you didn’t found him?", ["Not Found","No"], vc: self, kAlertRed) { [self] action in
            if(action == 1){
                self.jobRequestType(APIsEndPoints.kNoShow.rawValue)
            }
        }
    }
}
