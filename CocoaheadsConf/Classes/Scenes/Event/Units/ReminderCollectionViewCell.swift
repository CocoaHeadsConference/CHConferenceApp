//
//  ReminderCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class ReminderCollectionViewCell: UICollectionViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor(hexString: "1abc9c")
        containerView.layer.cornerRadius = 4
        containerView.backgroundColor = color.withAlphaComponent(0.25)
        containerView.layer.borderColor = color.withAlphaComponent(0.35).cgColor
        containerView.layer.borderWidth = 1
        
    }

}
