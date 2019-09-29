//
//  SpeakerDetailHeaderCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Kingfisher

class SpeakerDetailHeaderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var speakerImageView: UIImageView!
    @IBOutlet private var speakerNameLabel: UILabel!
    @IBOutlet private var speakerTwitterLabel: UILabel!
    
    var imageURL: URL? {
        didSet {
            speakerImageView.kf.setImage(with: imageURL, placeholder: ConferenceStyleKit.imageOfCocoaHeadsLogo, options: nil, progressBlock: nil) { _ in }
        }
    }
    
    var name: String? {
        didSet {
            speakerNameLabel.text = name
        }
    }
    
    var twitter: String? {
        didSet {
            if let twitter = twitter {
                speakerTwitterLabel.text = "@\(twitter)"
            }
            else {
                speakerTwitterLabel.text = ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        speakerImageView.layer.borderColor = Theme.shared.shadowColor.withAlphaComponent(0.8).cgColor
        speakerImageView.layer.borderWidth = 2
        speakerImageView.layer.cornerRadius = 40
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageURL = nil
        name = nil
        twitter = nil
    }
}
