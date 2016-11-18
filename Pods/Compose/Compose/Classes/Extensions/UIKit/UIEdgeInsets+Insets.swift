//
//  UIEdgeInsets+Insets.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/** 
 Adding simple inits to help create insets
 */
public extension UIEdgeInsets {
    
    /// Init with optional values. If any value is not provided, it will be treated as `0`
    ///
    /// - parameter top:      top inset
    /// - parameter leading:  left inset
    /// - parameter bottom:   bottom inset
    /// - parameter trailing: right inset
    public init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) {
        self = UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }
    
    /// Init with same value for Left/Right and also 0 for Top/Bottom
    ///
    /// - parameter horizontal: value to use for `left` and `right`
    public init(horizontal: CGFloat) {
        self = UIEdgeInsets(top: 0, left: horizontal, bottom: 0, right: horizontal)
    }
    
    /// Init with same value for Top/Bottom and also 0 for Left/Right
    ///
    /// - parameter vertical: value to use for `Top` and `Bottom`
    public init(vertical: CGFloat) {
        self = UIEdgeInsets(top: vertical, left: 0, bottom: vertical, right: 0)
    }
    
    /// Init with same value for all insets
    ///
    /// - parameter all: value to use for all insets
    public init(_ all: CGFloat) {
        self = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
    }
    
    /// Sum for `Left` and 'Right` insets
    public var horizontalInsets: CGFloat {
        return self.left + self.right
    }
    
    /// Sum for `Top` and 'Bottom` insets
    public var verticalInsets: CGFloat {
        return self.top + self.bottom
    }
    
}
