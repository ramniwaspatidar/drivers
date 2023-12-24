
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore

class TrackingViewController: BaseViewController,Storyboarded {
   
    var coordinator: MainCoordinator?
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    

    var viewModel : TrackingViewModel = {
        let model = TrackingViewModel()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI(){
        TrackingCell.registerWithTable(tblView)
        viewModel.infoArray = self.viewModel.prepareInfo()
    }
    @IBAction func confirmButtonAction(_ sender: Any) {
        coordinator?.goToArrivalView()
    }
    @IBAction func moreButtonActrion(_ sender: Any) {
        let alertController = UIAlertController(title: "Booking Action", message: "", preferredStyle: .actionSheet)
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = hexStringToUIColor("#F4CC9E")
        alertController.view.tintColor = UIColor.black

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let canclebooking = UIAlertAction(title: "Cancel Booking", style: .default) { action in
            print("Cancel Booking")
        }
        let callDriver = UIAlertAction(title: "Call Driver", style: .default) { action in
            print("Call Driver")
        }

        alertController.addAction(canclebooking)
        alertController.addAction(callDriver)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

// UITableViewDataSource
extension TrackingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.infoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: TrackingCell.reuseIdentifier, for: indexPath) as! TrackingCell
        cell.selectionStyle = .none
        cell.commiInit(viewModel.infoArray[indexPath.row])
        
        return cell
    }
}

extension TrackingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
}



