//
//  TrackingCell.swift
//  Knowitall Customer
//
//  Created by Ramniwas Patidar on 12/12/23.
//

import UIKit



import UIKit

class TrackingCell: ReusableTableViewCell {
    @IBOutlet weak var trakingLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func commiInit<T>(_ dictionary :T){
        if let dict = dictionary as? TrackingModel{
            trakingLabel.text = dict.value
            trakingLabel.textColor = hexStringToUIColor(dict.color)
            trakingLabel.text = dict.eta
            if(dict.status == "pending"){
                checkImage.image = UIImage(named: "uncheck")

            }else{
                checkImage.image = UIImage(named: "check")
            }
            
        }
       
    }
    
    fileprivate func setValue(){
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

