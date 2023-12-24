import UIKit
import FirebaseAuth
import SideMenu


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
               imageView.frame = CGRect(x: view.frame.width - 200, y: 0, width: 200, height: 200)
               tableView.tableHeaderView = imageView
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
        return CGFloat(70)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //        navigateUserTo(index: indexPath.row)
    }
}
