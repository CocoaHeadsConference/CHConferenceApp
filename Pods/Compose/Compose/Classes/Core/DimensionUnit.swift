//
//  DimensionUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Represents a calculated dimension based on some size constraint
public struct DimensionUnit: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {

    /// Closure that receives a CGSize and returns the calculated value
    private let calculationBlock: (CGSize)-> CGFloat
    
    /// Conforms to ExpressibleByIntegerLiteral
    /// Allows for the sintaxe `let x: DimensionUnit = 44`
    ///
    /// - parameter value: the fixed value that will be returned
    ///
    /// - returns: the passed value, independent from the size provided
    public init(integerLiteral value: Int) {
        self.init(value)
    }
    
    /// Conforms to ExpressibleByFloatLiteral
    /// Allows for the sintaxe `let x: DimensionUnit = 44.0`
    ///
    /// - parameter value: the fixed value that will be returned
    ///
    /// - returns: the passed value, independent from the size provided
    public init(floatLiteral value: Double) {
        self.init(value)
    }
    
    /// Creates a DimensionUnit from an Integer
    ///
    /// - parameter integer: the fixed value that will be returned
    ///
    /// - returns: the passed value, independent from the size provided
    public init(_ integer: Int) {
        self.calculationBlock = { _ in return CGFloat(integer) }
    }
    
    /// Creates a DimensionUnit from a Float
    ///
    /// - parameter floatValue: the fixed value that will be returned
    ///
    /// - returns: the passed value, independent from the size provided
    public init(_ floatValue: Float) {
        self.calculationBlock = { _ in return CGFloat(floatValue) }
    }
    
    /// Creates a DimensionUnit from a Double
    ///
    /// - parameter floatValue: the fixed value that will be returned
    ///
    /// - returns: the passed value, independent from the size provided
    public init(_ doubleValue: Double) {
        self.calculationBlock = { _ in return CGFloat(doubleValue) }
    }
    
    /// DimensionUnit that returns a dynamic dimension, based on the percentual of the **width** it will receive
    ///
    /// - parameter percentual: the percentual to be applied
    ///
    /// - returns: the **width** percentual, using Floor to **round** the value.
    public init(widthPercent percentual: Float) {
        self.calculationBlock = { size in
            return size.width * CGFloat(percentual)
        }
    }
    
    /// DimensionUnit that returns a dynamic dimension, based on the percentual of the **height** it will receive
    ///
    /// - parameter percentual: the percentual to be applied
    ///
    /// - returns: the **height** percentual, using Floor to **round** the value.
    public init(heightPercent percentual: Float) {
        self.calculationBlock = { size in
            return size.height * CGFloat(percentual)
        }
    }

    /// DimensionUnit that returns a dynamic dimension, based on the total of the **width** it will receive minus the reduction value
    ///
    /// - parameter reductor: value to subtract
    ///
    /// - returns: the **width** received minus the reductor parameter
    public init(minusWidth reductor: Float) {
        self.calculationBlock = { size in
            return size.width - CGFloat(reductor)
        }
    }
    
    /// DimensionUnit that returns a dynamic dimension, based on the total of the **height** it will receive minus the reduction value
    ///
    /// - parameter reductor: value to subtract
    ///
    /// - returns: the **height** received minus the reductor parameter
    public init(minusHeight reductor: Float) {
        self.calculationBlock = { size in
            return size.height - CGFloat(reductor)
        }
    }
    
    /// DimensionUnit that returns a dynamic dimension with a custom logic
    ///
    /// - parameter custom: closure with custom logic to apply
    ///
    /// - returns: custom value based on the size provided
    public init(custom: @escaping ((CGSize)-> CGFloat)) {
        self.calculationBlock = custom
    }
    
    /// Executes the calculation closure with the supplied size and returns the calculated value
    ///
    /// - parameter size: size to use in calculation
    ///
    /// - returns: dimension calculated
    public func value(for size: CGSize)-> CGFloat {
        let value = floor(calculationBlock(size))
        return value
    }
    
}
