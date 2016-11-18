//
//  ProducerUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 17/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

private protocol ProducerUnit: ComposingUnit {

    /// method that will create an empty view that later will be configured
    ///
    /// - returns: an UIView that can be added to any kind of view container.
    func createView()-> UIView
    
}
