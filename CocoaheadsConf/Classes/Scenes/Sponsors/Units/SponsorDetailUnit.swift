//
//  SponsorDetailUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 22/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose
import Kingfisher

func ListDetailUnit(for sponsor: SponsorModel, callback: ((SponsorModel)-> Void)?)-> ComposingUnit {
    var unit = ViewUnit<UIImageView>(id: "\(sponsor.id)", traits: [.height(DimensionUnit(widthPercent: 0.4))]) { view in
        view.backgroundColor = .white
        view.superview?.backgroundColor = .white
        view.contentMode = .center
        view.kf.setImage(with: sponsor.image)
    }
    unit.didSelectCallback = {
        callback?(sponsor)
    }
    return unit
}
