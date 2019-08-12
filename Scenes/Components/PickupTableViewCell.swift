//
//  PickupTableViewCell.swift
//  Pickup
//
//  Created by MECHIN on 8/9/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PickupTableViewCell: UITableViewCell {

    static let cellIdentifier = "PickupTableViewCellIdentifier"
   
    @IBOutlet var pickupImageView: UIImageView!
    @IBOutlet var pickupButton: UIButton!
    @IBOutlet var aliasLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var address1Label: UILabel!
    
    @IBOutlet var distanceLabel: UILabel!
   
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureLayoutWith(_ pickupItem: PickupTableViewCellData) {
        aliasLabel.text = pickupItem.data.alias
        cityLabel.text = pickupItem.data.city
        address1Label.text = pickupItem.data.address1
        
        if let distance = pickupItem.distanceInKiloMeters {
            distanceLabel.text = String(format: "%.2f km", distance)
        }else {
            distanceLabel.text = ""
        }
        
        if pickupItem.isSelected {
            pickupImageView.image = UIImage(named: "checked_checkbox")
        }else {
            pickupImageView.image = UIImage(named: "unchecked_checkbox")
        }
    }
    
}
