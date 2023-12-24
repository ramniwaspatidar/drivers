//
//  SettingCell.swift
//  Soliterra
//
//  Created by Ramniwas Easyeat on 04/02/23.
//

import UIKit

class SettingCell: ReusableTableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func commonInit(_ dict : SettingModel){
        img.image = dict.image
        lblName.text = dict.name
        
    }
    
}
