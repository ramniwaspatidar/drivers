//
//  RequestCell.swift
//  Knowitall Customer
//
//  Created by Ramniwas Patidar on 28/12/23.
//

import UIKit

class RequestCell: ReusableTableViewCell {
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func commonInit(_ dict : RequestListModal){
        requestLabel.text = "Request ID : \(dict.requestId ?? "")"
        dateLabel.text = AppUtility.getDateFromTimeEstime(dict.requestDate ?? 0.0)
        
        if(dict.confirmArrival == true){
            statusLabel.text = "Completed"
            statusLabel.textColor = .green
        }
       else if(dict.driverArrived == true){
            statusLabel.text = "Arrived"
            statusLabel.textColor = .yellow
        }
        else {
             statusLabel.text = "Ongoing"
             statusLabel.textColor = .yellow
         }
       
        
    }
    
    
   
}
