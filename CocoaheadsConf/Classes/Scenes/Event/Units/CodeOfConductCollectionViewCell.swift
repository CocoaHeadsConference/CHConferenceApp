//
//  CodeOfConductCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class CodeOfConductCollectionViewCell: UICollectionViewCell {

    @IBOutlet var textLabel: UILabel!
    
    var mainColor: UIColor? {
        didSet {
            self.contentView.backgroundColor = mainColor?.withAlphaComponent(0.2)
            textLabel.textColor = mainColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
