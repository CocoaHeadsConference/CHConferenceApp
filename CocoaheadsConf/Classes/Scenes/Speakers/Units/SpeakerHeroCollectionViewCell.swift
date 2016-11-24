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
            speakerImageView.tintColor = .white
            speakerImageView.kf.setImage(with: speakerImageURL, placeholder: ConferenceStyleKit.imageOfCocoaHeadsLogo, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    var speakerName: String? {
        didSet {
            speakerNameLabel.text = speakerName
        }
    }
    
    var speakerTwitter: String? {
        didSet {
            speakerTwitterLabel.text = speakerTwitter
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.backgroundColor = UIColor(hexString: "004D40")
        self.speakerImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        self.speakerImageView.layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.speakerImageView.layer.cornerRadius = self.speakerImageView.frame.width / 2
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        speakerImageURL = nil
        speakerName = nil
        speakerTwitter = nil
    }
    
}
