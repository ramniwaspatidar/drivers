
import UIKit
import WebKit

enum WebViewType :Int{
    case TC
    case policy
    case aboutus
}
class WKWebViewController: BaseViewController,Storyboarded {
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var webView: WKWebView!
    
    var webViewType : WebViewType?
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        
        super.viewDidLoad()
        
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)

        
    }
    
}
