//
//  TalkDetailDescriptionCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 21/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalkDetailDescriptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var videoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
