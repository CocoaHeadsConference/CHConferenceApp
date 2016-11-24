//
//  SpeakerDetailDescriptionCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakerDetailDescriptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var bioLabel: UILabel!
    @IBOutlet private var headlineLabel: UILabel!
    
    var bio: NSAttributedString? {
        didSet {
            bioLabel.attributedText = bio
        }
    }
    
    var headline: NSAttributedString? {
        didSet {
            headlineLabel.attributedText = headline
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bio = nil
    }

}
