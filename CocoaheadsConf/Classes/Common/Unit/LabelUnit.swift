//
//  LabelUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct LabelUnit: TypedUnit {

    typealias Cell = LabelCollectionViewCell
    
    let identifier: String
    let attributedText: NSAttributedString
    let heightUnit: DimensionUnit
    
    init(id: String, text: String, font: UIFont, color: UIColor, verticalSpace: CGFloat) {
        self.identifier = id
        let attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: color, .font: font])
        self.attributedText = attributedText
        self.heightUnit = DimensionUnit { size in
            let reductedSize = CGSize(width: size.width - 32, height: size.height)
            let frame = attributedText.boundingRect(with: reductedSize, options: .usesLineFragmentOrigin, context: nil)
            return round(frame.height) + verticalSpace
        }
    }
    
    func configure(innerView: Cell) {
        innerView.textLabel.attributedText = attributedText
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
