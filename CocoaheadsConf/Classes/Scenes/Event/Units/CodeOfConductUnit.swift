//
//  CodeOfConductUnit.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct CodeOfConductUnit: TypedUnit, SelectableUnit {
    
    typealias Cell = CodeOfConductCollectionViewCell
    
    let identifier = "CodeOfCoduct"
    let heightUnit: DimensionUnit = 48
    
    let color: UIColor
    var callback: ((Void)-> Void)?
    
    func configure(innerView: Cell) {
        innerView.mainColor = color
    }
    
    func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
    func didSelect() {
        self.callback?()
    }

}
