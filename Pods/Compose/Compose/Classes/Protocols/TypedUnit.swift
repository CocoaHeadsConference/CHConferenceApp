//
//  TypedUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 31/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// A TypedUnit can have an specialized version of the configure method, where it will receive the view to configure already casted to a specific type
public protocol TypedUnit: ComposingUnit {

    associatedtype InnerView: UIView
    
    /// Specialized method that will receive the view already casted
    ///
    /// - Parameter innerView: the view to configure already casted to **InnerView**
    func configure(innerView: InnerView)
    
}

public extension TypedUnit {

    /// Default implementation that tries to cast the received view to InnerView
    public func configure(view: UIView) {
        guard let cell = view as? InnerView else { return }
        configure(innerView: cell)
    }
    
}
