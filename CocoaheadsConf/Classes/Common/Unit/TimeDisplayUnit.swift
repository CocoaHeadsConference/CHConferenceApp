//
//  TimeDisplayUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct TimeDisplayUnit: TypedUnit {
    
    let identifier: String
    let heightUnit: DimensionUnit = 68
    let date: Date
    private let timeDateFormatter: DateFormatter
    
    init(date: Date) {
        self.identifier = "\(date.timeIntervalSince1970)"
        self.date = date
        self.timeDateFormatter = DateFormatter()
    }
    
    func configure(innerView: TimeDisplayCollectionViewCell) {
        innerView.backgroundColor = .clear
        timeDateFormatter.dateFormat = "eeee, dd/MM"
        innerView.dayLabel.text = timeDateFormatter.string(from: date).capitalized
    }
    
    func reuseIdentifier() -> String {
        return InnerView.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        InnerView.register(in: collectionView)
    }
    
}
