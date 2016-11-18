//
//  UIView+Extensions.swift
//  Compose
//
//  Created by Bruno Bilescky on 05/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Adding nib discovery and identifier for every UIView
public extension UIView {
    
    /// Will try to find a XIB with the same name as the class in it's bundle.
    ///
    /// - returns: the nib if found
    public static func nibForSelf()-> UINib? {
        let bundle = Bundle(for: self)
        let name = shortName(for: self)
        guard let path = bundle.path(forResource: name, ofType: "nib"), FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        return UINib(nibName: name, bundle: bundle)
    }
    
    /// give each UIView an identifier we can use
    ///
    /// - returns: the short class name
    public static func identifier()-> String {
        return shortName(for: self)
    }
    
}

func shortName(for cls: AnyClass)-> String {
    let className = "\(cls)".components(separatedBy: ".").last ?? "\(cls)"
    return className
}
