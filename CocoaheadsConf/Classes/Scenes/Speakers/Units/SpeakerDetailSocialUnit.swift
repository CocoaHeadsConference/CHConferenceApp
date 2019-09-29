//
//  SpeakerDetailSocialUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 16/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose


func SpeakerDetailAllSocialUnit(twitter: String, linkedIn: String, github: String)-> ComposingUnit {
    var units: [ComposingUnit] = []
    units.add(if: twitter.count > 0) { SpeakerDetailSocialUnit(socialType: .Twitter, handler: twitter) }
    units.add(if: linkedIn.count > 0) { SpeakerDetailSocialUnit(socialType: .LinkedIn, handler: linkedIn) }
    units.add(if: github.count > 0) { SpeakerDetailSocialUnit(socialType: .Github, handler: github) }
    
    return CollectionStackUnit(identifier: "social", direction: .verticalGrid(columns: units.count), traits: [], units: units) { (collectionView) in
        guard units.count > 1, let item = units[1] as? SpeakerDetailSocialUnit else { return }
        collectionView.backgroundColor = item.socialType.backgroundColor
    }
}

struct SpeakerDetailSocialUnit: TypedUnit {
    
    typealias Cell = SpeakerDetailSocialCollectionViewCell
    
    enum SocialType: String {
        case Twitter, LinkedIn, Github
        
        var backgroundColor: UIColor {
            switch self {
            case .Twitter:
                return UIColor(hexString: "55acee")
            case .LinkedIn:
                return UIColor(hexString: "0077B5")
            case .Github:
                return UIColor(hexString: "2f2f2f")
            }
        }
    }
    
    
    let socialType: SocialType
    let handler: String
    
    
    var identifier: String {
        return "item-\(self.socialType)"
    }
    
    let heightUnit: DimensionUnit = 52
    
    func configure(innerView: Cell) {
        innerView.socialColor = socialType.backgroundColor
        innerView.socialHandler = self.socialType.rawValue
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
