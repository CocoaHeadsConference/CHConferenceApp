//
//  ComposingUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/** A ComposingUnit represents an unit that knows how to display some data inside some View.
 */
public protocol ComposingUnit {
    
    /// Unit identifier
    var identifier: String { get }
    
    /// Height dimension
    var heightUnit: DimensionUnit { get }
    
    
    /// Width dimension
    var widthUnit: DimensionUnit { get }
    
    /// You can customize and fill your view with data inside this method
    ///
    /// - parameter view: the view to be customized. You may want to cast it to your specific view class
    ///
    func configure(view: UIView)
    
    /// Reuse identifier for this Unit. Used inside collectionViews and tableViews to manage reuse for cells
    ///
    /// - returns: the reuse identifier for this unit
    func reuseIdentifier()-> String
    
    /// Register a collectionViewCell, so we can dequeue these cells later inside collectionViews
    ///
    /// - parameter collectionView: the collectionView to register the cell
    func register(in collectionView: UICollectionView)
    
    /// Register a tableViewCell, so we can dequeue these cells later inside tableViews
    ///
    /// - parameter tableView: the tableView to register the cell
    func register(in tableView: UITableView)
    
}

// MARK: - Default Implementation
public extension ComposingUnit {
    
    /// Default to 0
    var heightUnit: DimensionUnit {
        return 0
    }
    
    /// Default to 0
    var widthUnit: DimensionUnit {
        return 0
    }
    
    /// Default implementation throw error on invocation. Must be implemented before this unit can be used inside a `UICollectionView`
    func register(in collectionView: UICollectionView) {
        fatalError("You should implement ths method before using it")
    }
    
    /// Default implementation throw error on invocation. Must be implemented before this unit can be used inside a `UITableView`
    public func register(in tableView: UITableView) {
        fatalError("You should implement ths method before using it")
    }
    
}
