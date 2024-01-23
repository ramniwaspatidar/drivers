import UIKit
import FirebaseAuth
import SideMenu
import FirebaseMessaging

class SideMenuTableViewController: UIViewController, Storyboarded  {
    
    var coordinator: MainCoordinator?
    
    var tableView: UITableView!
    
    lazy var viewModel : SettingViewModel = {
        let viewModel = SettingViewModel()
        return viewModel }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = hexStringToUIColor("6E04F8")
        viewModel.settingArray =  viewModel.prepareInfo()
        
        // Initialize and configure the UITableView
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register a UITableViewCell class or reuse identifier if needed
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        // Add the UITableView to the view hierarchy
        view.addSubview(tableView)
        
        // Set up constraints (you can customize these according to your layout)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        SettingCell.registerWithTable(tableView)
        
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit // Adjust content mode as needed
        imageView.frame = CGRect(x: (view.frame.width - 175)/2, y: 0, width: 175, height: 175)
        tableView.tableHeaderView = imageView
        
        
        let button = UIButton(frame: CGRect(x: 20, y: 300, width: 200, height: 60))
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(hexStringToUIColor("#00F2EA"), for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left

    }

    
    func buttonTapped() {
        
        do{
            try Auth.auth().signOut()
            
            Messaging.messaging().unsubscribe(fromTopic: CurrentUserInfo.userId) { error in
                if let error = error {
                    print("Error unsubscribing from topic: \(error.localizedDescription)")
                } else {
                    print("Successfully unsubscribed from topic!")
                }
            }
            
            CurrentUserInfo.email = nil
            CurrentUserInfo.phone = nil
            CurrentUserInfo.vehicleNumber = nil
            CurrentUserInfo.userName = nil
            CurrentUserInfo.profileUrl = nil
            CurrentUserInfo.language = nil
            CurrentUserInfo.location = nil
            CurrentUserInfo.userId = nil
            
            let menu = SideMenuManager.default.leftMenuNavigationController
            menu?.enableSwipeToDismissGesture = false

            menu?.dismiss(animated: false, completion: {
                let  appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.autoLogin()
            })
            
        }catch{
            
        }
        
    }

    
}

extension SideMenuTableViewController: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseIdentifier, for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        
        cell.commonInit(viewModel.settingArray[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coordinator =  appDelegate?.coordinator   //MainCoordinator(navigationController: self.navigationController!)
        
        var isDismiss = true
          
        if(indexPath.row == 0){
            coordinator?.goToHome(true)
            
        }else if(indexPath.row == 1){
            coordinator?.goToRequestList()
        }
        else if(indexPath.row == 2){//Available Jobs
            coordinator?.goToRequestList(true)
        }
        else if(indexPath.row == 3){// My Account
            coordinator?.goToUpdateProfile()
        }
        else if(indexPath.row == 4){// Change password
            coordinator?.gotoChangePassword()
        }
        else if(indexPath.row == 5){
            coordinator?.goToWebview(type: .TC, true)
        }
        
        else if(indexPath.row == 6){
            coordinator?.goToWebview(type: .FAQ)
        }
        else if(indexPath.row  == 7){
            isDismiss = false
            if(CurrentUserInfo.dutyStarted == true){
                Alert(title: "Logout", message: "Please make yourself unavailable and try logging out again.", vc: self)
                
            }else{
                AlertWithAction(title:"Logout", message: "Are you sure that you want to Sign out from app?", ["Yes, Sign out","No"], vc: self, kAlertRed) { [self] action in
                    if(action == 1){
                        self.buttonTapped()
                    }
                }
            }
        }
        
        
        if(isDismiss){
            dismiss(animated: true, completion: nil)

        }

    }
}
