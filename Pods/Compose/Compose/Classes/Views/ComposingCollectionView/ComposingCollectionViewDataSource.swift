//
//  ComposingCollectionViewDataSource.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// DataSource for our CollectionView, providing the right cell to be displayed by each unit
class ComposingCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    let source: ComposingDataSource
    
    init(with source: ComposingDataSource) {
        self.source = source
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.numberOfUnits()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let unit = source[indexPath.item]
        let reuseIdentifier = unit.reuseIdentifier()
        if source.needsRegister(identifier: reuseIdentifier) {
            unit.register(in: collectionView)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        unit.configure(view: cell)
        return cell
    }
    
}
