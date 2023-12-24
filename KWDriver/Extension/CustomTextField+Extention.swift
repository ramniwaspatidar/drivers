

import Foundation
import UIKit
class CustomTextField : UITextField{
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initializeTextField(){
        let fontName = self.font?.fontName
        self.font = self.font!.setFont(fontName!, self.font!)
    }
}

