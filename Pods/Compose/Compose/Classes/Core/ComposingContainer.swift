//
//  ComposingContainer.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// protocol that defines what a view must conform to be a container for Compose
public protocol ComposingContainer: class {

    /// The direction that units will follow inside this container
    var direction: ComposingContainerDirection { get set }
    
    /// State that will be used to compose the view
    var state: [ComposingUnit] { get set }
    
}
