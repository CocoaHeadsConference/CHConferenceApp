//
//  SpeakerDetailSmallTalkCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 21/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakerDetailSmallTalkCollectionViewCell: UICollectionViewCell {

    @IBOutlet var talkTimeLabel: UILabel!
    @IBOutlet var talkTitleLabel: UILabel!
    @IBOutlet var talkRoomLabel: UILabel!
    @IBOutlet var talkTypeIndicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
