//
//  SpeakerHeroCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Kingfisher

class SpeakerHeroCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var speakerImageView: UIImageView!
    @IBOutlet private var speakerNameLabel: UILabel!

    var speakerImageURL: URL? {
        didSet {
            speakerImageView.kf.setImage(with: speakerImageURL, placeholder: #imageLiteral(resourceName: "cocoaheads_teammember"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    var speakerName: String? {
        didSet {
            speakerNameLabel.text = speakerName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        self.layer.borderWidth = 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        speakerImageURL = nil
        speakerName = nil
    }
    
}
