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
    let heightUnit: DimensionUnit = 60
    let date: Date
    let hideUpperLine: Bool
    private let timeDateFormatter: DateFormatter
    
    init(date: Date, format: String = "eeee", hideUpperLine: Bool) {
        self.identifier = "\(date.timeIntervalSince1970)"
        self.date = date
        self.hideUpperLine = hideUpperLine
        self.timeDateFormatter = DateFormatter()
        self.timeDateFormatter.dateFormat = format
    }
    
    func configure(innerView: TimeDisplayCollectionViewCell) {
        innerView.backgroundColor = .clear
        innerView.timeLabel.text = timeDateFormatter.string(from: date).capitalized
        innerView.hideUpperLine = hideUpperLine
    }
    
    func reuseIdentifier() -> String {
        return InnerView.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        InnerView.register(in: collectionView)
    }
    
}
