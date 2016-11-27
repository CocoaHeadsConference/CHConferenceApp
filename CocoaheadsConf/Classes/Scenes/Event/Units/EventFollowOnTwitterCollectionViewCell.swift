//
//  EventFollowOnTwitterCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class EventFollowOnTwitterCollectionViewCell: UICollectionViewCell {

    @IBOutlet var twitterImageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    
    var mainColor: UIColor? {
        didSet {
            self.contentView.backgroundColor = mainColor?.withAlphaComponent(0.2)
            twitterImageView.tintColor = mainColor
            textLabel.textColor = mainColor
        }
    }
    
    var twitterHandle: String? {
        didSet {
            guard let handle = twitterHandle else {
                textLabel.text = nil
                return
            }
            textLabel.text = "Siga @\(handle)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
