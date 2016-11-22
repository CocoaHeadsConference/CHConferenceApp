//
//  DetailHeaderCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 20/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class DetailHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet var talkNameLabel: UILabel!
    @IBOutlet var talkTimeLabel: UILabel!
    @IBOutlet var talkLocationLabel: UILabel!
    @IBOutlet var talkIndicatorView: UIView!
    @IBOutlet var talkSpeakerImageView: UIImageView!
    @IBOutlet var backButton: UIButton!
    
    var tapGoBackCallback: (()-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        talkSpeakerImageView.layer.cornerRadius = 36
        talkSpeakerImageView.backgroundColor = UIColor(hexString: "004D40")
        talkSpeakerImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.7).cgColor
        talkSpeakerImageView.layer.borderWidth = 3
        backButton.setTitle(nil, for: [])
        backButton.setImage(ConferenceStyleKit.imageOfBackButton, for: [])
    }
    
    @IBAction func didTapGoBack() {
        tapGoBackCallback?()
    }

}
