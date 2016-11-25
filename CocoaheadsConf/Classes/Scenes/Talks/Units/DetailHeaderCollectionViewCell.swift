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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        talkSpeakerImageView.layer.cornerRadius = 36
        talkSpeakerImageView.backgroundColor = Theme.shared.mainColor
        talkSpeakerImageView.layer.borderColor = Theme.shared.shadowColor.withAlphaComponent(0.7).cgColor
        talkSpeakerImageView.layer.borderWidth = 2
    }

}
