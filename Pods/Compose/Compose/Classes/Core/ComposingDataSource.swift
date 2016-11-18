//
//  ComposingDataSource.swift
//  Compose
//
//  Created by Bruno Bilescky on 17/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

class ComposingDataSource: NSObject {

    private var registeredCellIdentifiers: Set<String> = []
    var state: [ComposingUnit]
    
    /// Init with initial state to be displayed
    ///
    /// - parameter initialState: the initial state
    ///
    init(initialState:[ComposingUnit] = []) {
        self.state = initialState
    }
    
    func numberOfUnits()-> Int {
        return state.count
    }
    
    subscript(_ index: Int)-> ComposingUnit {
        precondition(index < numberOfUnits(), "Index should be smaller than the number of states")
        return state[index]
    }
    
    func needsRegister(identifier: String)-> Bool {
        guard !registeredCellIdentifiers.contains(identifier) else { return false }
        registeredCellIdentifiers.insert(identifier)
        return true
    }
    
}
