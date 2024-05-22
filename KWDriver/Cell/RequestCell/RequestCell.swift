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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.black.cgColor
        bgView.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getAddressString(_ dict : RequestListModal) -> String {
        var addressString = ""
        
        if let address = dict.address, !address.isEmpty {
            addressString += address + ", "
        }
        if let address1 = dict.address1, !address1.isEmpty {
            addressString += address1 + ", "
        }
        if let landMark = dict.landMark, !landMark.isEmpty {
            addressString += landMark + ", "
        }
        
        if let city = dict.city, !city.isEmpty {
            addressString += city + ", "
        }
        if let state = dict.state, !state.isEmpty {
            addressString += state + ", "
        }
        if let postalCode = dict.postalCode, !postalCode.isEmpty {
            addressString += postalCode + ", "
        }
        if let country = dict.country, !country.isEmpty {
            addressString += country
        }
        
        // Trim trailing comma and space if they exist
        addressString = addressString.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        
        // Replace consecutive commas with a single comma
        addressString = addressString.replacingOccurrences(of: ", , ", with: ", ")
        
        return addressString
    }
    
    
    func  commonInit(_ dict : RequestListModal){
        requestLabel.text = "Request ID : \(dict.reqDispId ?? "")"
        nameLabel.text = dict.name
        
        addressLabel.text = getAddressString(dict)
        dateLabel.text = AppUtility.getDateFromTimeEstime(dict.requestDate ?? 0.0)
        
        serviceLabel.text = dict.typeOfService
        
        var isReassign = false
        if(dict.isPending == 2) {
            if (dict.reassignDriverList != nil){
                let drivers = dict.reassignDriverList?.filter({ item  in
                    item.driverId == CurrentUserInfo.userId
                })
                if(drivers?.count ?? 0 > 0){
                    isReassign = true
                }
            }
            
            if(dict.isPendingSubStatus == 1){
                isReassign = true
            }
        }
        
        
        let drivers = dict.declineDrivers?.filter({ item  in
            item.driverId == CurrentUserInfo.userId
        })
        
        if(dict.completed == true){
            statusLabel.text = "Booking Completed"
            statusLabel.textColor = hexStringToUIColor("36D91B")
        }
        else if(drivers?.count ?? 0 > 0){
            statusLabel.text = "DECLINED"
            statusLabel.textColor = hexStringToUIColor("FF004F")
        }
        else if(dict.cancelled == true){
            statusLabel.text = "Cancelled"
            statusLabel.textColor = hexStringToUIColor("FF004F")
        }
        else  if(dict.markNoShow == true){
            statusLabel.text = "Tow Not Found"
            statusLabel.textColor = hexStringToUIColor("FF004F")
        }
        else if(dict.confirmArrival == true){
            statusLabel.text = "Arrival Confirmed"
            statusLabel.textColor = hexStringToUIColor("36D91B")
        }
        else if(dict.driverArrived == true){
            statusLabel.text = "Driver Arrived"
            statusLabel.textColor = hexStringToUIColor("F7D63D")
        }
        else if(dict.accepted == true){
            statusLabel.text = "Ongoing"
            statusLabel.textColor = hexStringToUIColor("F7D63D")
        }
        else {
            statusLabel.text = "Available"
            statusLabel.textColor = hexStringToUIColor("F7D63D")
        }
        
        if(isReassign){
            statusLabel.text = "\(statusLabel.text ?? "")(Reassign)"
        }
    }
}
