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
    @IBOutlet private var speakerTwitterLabel: UILabel!

    var speakerImageURL: URL? {
        didSet {
            speakerImageView.kf.setImage(with: speakerImageURL, placeholder: ConferenceStyleKit.imageOfCocoaHeadsLogo, options: nil, progressBlock: nil) { _ in }
        }
    }
    
    var speakerName: String? {
        didSet {
            speakerNameLabel.text = speakerName
        }
    }
    
    var speakerTwitter: String? {
        didSet {
            if let twitter = speakerTwitter {
                speakerTwitterLabel.text =  "@\(twitter)"
            }
            else {
                speakerTwitterLabel.text =  ""
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        speakerImageView.tintColor = .white
        self.speakerImageView.layer.borderColor = Theme.shared.shadowColor.withAlphaComponent(0.8).cgColor
        self.speakerImageView.layer.borderWidth = 1
        self.speakerImageView.layer.cornerRadius = 32
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        speakerImageURL = nil
        speakerName = nil
        speakerTwitter = nil
    }
    
}
