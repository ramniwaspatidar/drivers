
import UIKit
import FirebaseAuth
import Firebase

class RequestListViewController: BaseViewController,Storyboarded{
    
    var coordinator: MainCoordinator?
    var refreshControl: UIRefreshControl!

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

        self.setNavWithOutView(ButtonType.menu)
        RequestCell.registerWithTable(tblView)
        self.getAllRequestList()
        
//        coordinator?.goToJobView("a7859014-7a44-440d-a87c-e59347512496")


    }
    
    @objc func refresh(_ sender: Any) {
        refreshControl.endRefreshing()
        self.getAllRequestList()
    }
    
    func getAllRequestList(_ loading : Bool = true){
        viewModel.sendRequest(APIsEndPoints.requestList.rawValue) { response, code in
            
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
