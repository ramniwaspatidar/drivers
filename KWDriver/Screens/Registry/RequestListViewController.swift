
import UIKit
import FirebaseAuth
import Firebase

class RequestListViewController: BaseViewController,Storyboarded{
    
    var coordinator: MainCoordinator?
    @IBOutlet weak var tblView: UITableView!
   
    var viewModel : RequestListViewModal = {
        let model = RequestListViewModal()
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavWithOutView(ButtonType.menu)
        
        viewModel.sendRequest(APIsEndPoints.requestList.rawValue) { response, code in
            self.viewModel.listArray  = response
            self.tblView.reloadData()
        }
        RequestCell.registerWithTable(tblView)
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
//        
//        if(dictResponse.confirmArrival == false && dictResponse.arrivalCode != nil && dictResponse.driverArrived == true){
//            coordinator?.goToOTP(self.viewModel.listArray[indexPath.row])
//        }else{
        coordinator?.goToJobView(dictResponse.requestId!)
       // }
    }
}
