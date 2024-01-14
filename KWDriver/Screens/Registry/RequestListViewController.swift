
import UIKit
import FirebaseAuth
import Firebase

class RequestListViewController: BaseViewController,Storyboarded{
    
    var coordinator: MainCoordinator?
    var refreshControl: UIRefreshControl!
    var isJob : Bool = false
    @IBOutlet weak var headingTitle: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
   
    var viewModel : RequestListViewModal = {
        let model = RequestListViewModal()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tblView.addSubview(refreshControl)
        
        coordinator = MainCoordinator(navigationController: self.navigationController!)
        
        self.headingTitle.text = self.isJob ? "Available Jobs" : "MY JOBS"

        self.setNavWithOutView(ButtonType.menu)
        RequestCell.registerWithTable(tblView)
        self.getAllRequestList()
        

    }
    
    @objc func refresh(_ sender: Any) {
        refreshControl.endRefreshing()
        self.getAllRequestList()
    }
    
    func getAllRequestList(_ loading : Bool = true){
        
        
        
        let lat =  CurrentUserInfo.latitude
        let lng = CurrentUserInfo.longitude
        
        let latlng =  APIsEndPoints.kGetAvailableJoobs.rawValue +  "?latitude=\(lat ?? "0")&longitude=\(lng ?? "0")"
        
    
        let endpoint = self.isJob ? latlng : APIsEndPoints.requestList.rawValue
        
        
        viewModel.sendRequest(endpoint) { response, code in
            
            if(response.count > 0){
                self.viewModel.listArray  = response
                self.tblView.reloadData()
            }else{
                self.tblView.isHidden = true
                AppUtility.addPLaceHolderLabel("No jobs found", self.view)
            }
     
        }
        
        

    }
  
}
// UITableViewDataSource
extension RequestListViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listArray.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: RequestCell.reuseIdentifier, for: indexPath) as! RequestCell
        cell.selectionStyle = .none
        cell.commonInit(viewModel.listArray[indexPath.row])
        
        return cell
    }
}

extension RequestListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.defaultCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let dictResponse = self.viewModel.listArray[indexPath.row]
            coordinator?.goToJobView(dictResponse.requestId!)

    }
}
