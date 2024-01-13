

import UIKit
import WebKit

enum WebViewType :Int{
    case TC
    case policy
    case FAQ
}
class WKWebViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    var webViewType : WebViewType?
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        
        super.viewDidLoad()
        
        setNavWithOutView(.menu)
        loadHTMPPage()
        
    }
    
  

    fileprivate func loadHTMPPage(){
        if webViewType == WebViewType.TC{
            lblTitle?.text = "Terms & Condition"
            webView.load(URLRequest(url: URL(string: "https://discussions.apple.com/terms")!))
        }
        else if webViewType == WebViewType.policy{
            lblTitle?.text = "Privacy Policy"
            webView.load(URLRequest(url: URL(string: "https://discussions.apple.com/terms")!))
        }
        
        else if webViewType == WebViewType.FAQ
        {
            lblTitle?.text = "FAQ’s"
            webView.load(URLRequest(url: URL(string: "https://discussions.apple.com/terms")!))
        }
    }
    
}
