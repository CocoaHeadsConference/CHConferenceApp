//
//  TimeDisplayCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TimeDisplayCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet var upperLine: UIView! {
        didSet {
            upperLine.backgroundColor = TalkModel.TalkType.closing.color.withAlphaComponent(0.8)
        }
    }
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bottomLine: UIView! {
        didSet {
            bottomLine.backgroundColor = TalkModel.TalkType.setup.color.withAlphaComponent(0.8)
        }
    }
    
    var hideUpperLine: Bool = false {
        didSet {
            upperLine.isHidden = hideUpperLine
        }
    }

    var hideBottomLine: Bool = false {
        didSet {
            bottomLine.isHidden = hideBottomLine
        }
    }
    
}
