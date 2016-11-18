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
            speakerImageView.layer.cornerRadius = 26
            speakerImageView.layer.borderWidth = 2
        }
    }
    @IBOutlet var speakerNameLabel: UILabel!
    @IBOutlet var talkTitleLabel: UILabel!
    @IBOutlet var talkSummaryLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var cardContainerView: UIView! {
        didSet {
            cardContainerView.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
            cardContainerView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet var lineView: UIView!
    @IBOutlet var timeContainerView: UIView!

    var talkColor: UIColor? {
        didSet {
            let color = talkColor?.withAlphaComponent(0.8)
            lineView.backgroundColor = color
            timeContainerView.backgroundColor = color
            speakerImageView.backgroundColor = color
            speakerImageView.layer.borderColor = color?.cgColor
            cardContainerView.backgroundColor = talkColor?.withAlphaComponent(0.5)
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
