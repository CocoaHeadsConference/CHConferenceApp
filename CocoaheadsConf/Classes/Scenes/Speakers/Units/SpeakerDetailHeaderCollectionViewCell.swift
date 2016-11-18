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

    @IBOutlet private var speakerBlurImageView: UIImageView!
    @IBOutlet private var speakerImageView: UIImageView! {
        didSet {
            speakerImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
            speakerImageView.layer.borderWidth = 2
        }
    }
    @IBOutlet private var speakerNameLabel: UILabel!
    @IBOutlet private var speakerHeadlineLabel: UILabel!
    
    var imageURL: URL? {
        didSet {
            speakerBlurImageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "cocoaheads_teammember"), options: nil, progressBlock: nil, completionHandler: nil)
            speakerImageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "cocoaheads_teammember"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    var name: String? {
        didSet {
            speakerNameLabel.text = name
        }
    }
    
    var headline: String? {
        didSet {
            speakerHeadlineLabel.text = headline
        }
    }
    
    var closeCallback: (()-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageURL = nil
        name = nil
        headline = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        speakerImageView.layer.cornerRadius = speakerImageView.frame.width / 2
    }
    
    
    @IBAction func closeCard() {
        closeCallback?()
    }
}
