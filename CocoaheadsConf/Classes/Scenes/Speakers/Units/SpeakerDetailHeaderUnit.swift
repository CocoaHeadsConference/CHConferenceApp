//
//  SpeakerDetailHeaderUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct SpeakerDetailHeaderUnit: TypedUnit {

    typealias Cell = SpeakerDetailHeaderCollectionViewCell
    
    let identifier: String = "DetailHeader"
    
    let imageURL: URL
    let name: String
    let headline: String
    let citation: String
    let heightUnit: DimensionUnit
    let closeCallback: (()-> Void)?
    
    init(imageURL: URL, name: String, headline: String, citation: String, closeCallback: (()-> Void)?) {
        self.imageURL = imageURL
        self.name = name
        self.headline = headline
        self.citation = citation
        self.closeCallback = closeCallback
        
        heightUnit = DimensionUnit { size in
            let reducedSize = CGSize(width: size.width - 32, height: size.height)
            let font = UIFont.systemFont(ofSize: 15)
            let attributed = NSAttributedString(string: citation, attributes: [NSFontAttributeName: font])
            let frame = attributed.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            return round(frame.height) + 200
        }
    }
    
    func configure(innerView: Cell) {
        innerView.closeCallback = closeCallback
        innerView.imageURL = imageURL
        innerView.name = name
        innerView.headline = headline
        innerView.citation = citation
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
