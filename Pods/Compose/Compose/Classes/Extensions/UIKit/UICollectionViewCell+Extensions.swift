//
//  UICollectionViewCell+Extensions.swift
//  Compose
//
//  Created by Bruno Bilescky on 05/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Register UICollectionViewCell in UICollectionView
public extension UICollectionViewCell {
    
    /// Try to find a nib for this CollectionViewCell. If it finds one, register it to the collectionView, else it register the class itself
    ///
    /// - parameter collectionView: collectionView to register
    public static func register(in collectionView: UICollectionView, customIdentifier: String? = nil) {
        let identifier = customIdentifier ?? self.identifier()
        if let nib = nibForSelf() {
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
        else {
            collectionView.register(self, forCellWithReuseIdentifier: identifier)
        }
    }
    
}
