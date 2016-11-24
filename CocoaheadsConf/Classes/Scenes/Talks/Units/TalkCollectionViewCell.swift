//
//  TalkCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Kingfisher

class TalkCollectionViewCell: UICollectionViewCell {

    @IBOutlet var speakerImageView: UIImageView! {
        didSet {
            speakerImageView.layer.cornerRadius = 27
            speakerImageView.layer.borderWidth = 2
            speakerImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        }
    }
    
    @IBOutlet var videoImageView: UIImageView! {
        didSet {
            videoImageView.image = #imageLiteral(resourceName: "videos").withRenderingMode(.alwaysTemplate)
            videoImageView.tintColor = .white
        }
    }
    
    @IBOutlet var speakerNameLabel: UILabel!
    @IBOutlet var talkTitleLabel: UILabel!
    @IBOutlet var talkSummaryLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var cardContainerView: UIView! 
    
    @IBOutlet var kindIndicatorView: UIView!
    
    var talkColor: UIColor? {
        didSet {
            kindIndicatorView.backgroundColor = talkColor
            /*let color = talkColor
            placeLabel.textColor = talkColor
            timeLabel.textColor = talkColor
            speakerNameLabel.textColor = talkColor
            talkTitleLabel.textColor = talkColor
            talkSummaryLabel.textColor = talkColor
            speakerImageView.layer.borderColor = color?.cgColor
            cardContainerView.layer.borderColor = talkColor?.withAlphaComponent(0.8).cgColor
            cardContainerView.backgroundColor = .white// talkColor?.withAlphaComponent(0.25)
             */
        }
    }
    
    var speakerImageURL: URL? {
        didSet {
            speakerImageView.kf.setImage(with: speakerImageURL, placeholder: #imageLiteral(resourceName: "cocoaheads_teammember"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        speakerImageURL = nil
    }
    
}
