//
//  TwoStepDisplayUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 16/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/** Most people configure and define a cell inside the cellForItem/cellForRow method of the dataSource.
    But you can get some performance boost if you define the state of your cell in the WillDisplayItem/Row method instead
    This protocol represents an unit that will do the cell setup in two steps. You still can configure your cell in `configure:(view:)`. But you can also define it's state inside `beforeDisplay(view:)`
 */
public protocol TwoStepDisplayUnit {

    /// Entry point for the `willDisplayCell` that the collectionView/tableView delegate will call. You can define the state for your view here.
    ///
    /// - parameter view: the cell you are configuring
    func beforeDisplay(view: UIView)
    
    /// Entry point for the `didEndDisplayingCell` that the collectionView/tableView delegate will call. You can react to your cell been hided.
    ///
    /// - parameter view: cell that just got hidden
    func afterDisplay(view: UIView)
    
}


public extension TwoStepDisplayUnit {
    
    /// You don't need to add an empty implementation
    public func afterDisplay(view: UIView) {
        
    }
    
}
