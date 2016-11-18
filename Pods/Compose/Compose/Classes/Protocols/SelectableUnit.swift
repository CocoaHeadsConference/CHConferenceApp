//
//  SelectableUnit.swift
//  Pods
//
//  Created by Bruno Bilescky on 13/10/16.
//
//

import UIKit

/// Represents an unit that can be selected.
public protocol SelectableUnit: HighlightableUnit {

    func didSelect()
    func shouldSelect()-> Bool
    
}


public extension SelectableUnit {
    
    func didHightlight() {
        
    }
    
    func shouldSelect()-> Bool {
        return true
    }
    
}
