//
//  HighlightableUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 16/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Represents an unit that can be highlighted 
public protocol HighlightableUnit: ComposingUnit {

    /// Method that will be called when a cell is unhightlight
    func didUnhightlight()
    
    /// Method that will be called when a cell got highlighted
    func didHightlight()
    
}


public extension HighlightableUnit {
    
    /// Empty implementation so you don't need to add this to every HighlightableUnit
    public func didUnhightlight() {
        
    }
    
}
