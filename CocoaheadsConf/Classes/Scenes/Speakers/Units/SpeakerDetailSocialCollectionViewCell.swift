//
//  SpeakerDetailSocialCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakerDetailSocialCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var socialHandlerLabel: UILabel!
    
    var socialColor: UIColor? {
        didSet {
            self.contentView.backgroundColor = socialColor
        }
    }
    
    var socialHandler: String? {
        didSet {
            self.socialHandlerLabel.text = socialHandler
        }
    }

}
