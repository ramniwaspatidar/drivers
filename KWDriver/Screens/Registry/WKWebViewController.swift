

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
        if((self.navigationController?.viewControllers.count)! >= 2){
            setNavWithOutView(.back)
        }
        else{
            setNavWithOutView(.menu)
        }
        
        loadHTMPPage()
    }
    
  

    fileprivate func loadHTMPPage(){
        if webViewType == WebViewType.TC{
            lblTitle?.text = "Terms & Condition"
            
            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "pdf") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        else if webViewType == WebViewType.policy{
            lblTitle?.text = "Privacy Policy"
            if let htmlPath = Bundle.main.path(forResource: "terms", ofType: "pdf") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        
        else if webViewType == WebViewType.FAQ
        {
            lblTitle?.text = "FAQ’s"
            
            if let htmlPath = Bundle.main.path(forResource: "faq", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
    
}
