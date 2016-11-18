//
//  ViewTraits.swift
//  Pods
//
//  Created by Bruno Bilescky on 07/10/16.
//
//

import UIKit

/// ViewTraits are options you can pass to a ViewUnit to configure the container cell for your custom class.
public enum ViewTraits {
    //Styles
    /// backgroundColor for the cell
    case backgroundColor(UIColor)
    
    /// insets for the cell
    case insets(UIEdgeInsets)
    
    /// should the cell be opaque?
    case opaque(Bool)
    
    //DimensionUnits
    /// height for this unit
    case height(DimensionUnit)
    
    ///width for this unit
    case width(DimensionUnit)
    
    /// Return the style values contained inside the traits array
    ///
    /// - parameter traits: a collection of traits
    ///
    /// - returns: a tuple with all style values
    public static func mapStyle(from traits: [ViewTraits])-> (backgroundColor: UIColor, insets: UIEdgeInsets, opaque: Bool) {
        var backgroundColor: UIColor = .clear
        var insets: UIEdgeInsets = .zero
        var opaque = false
        for trait in traits {
            switch trait {
            case let .backgroundColor(color):
                backgroundColor = color
            case let .insets(refInsets):
                insets = refInsets
            case let .opaque(boolean):
                opaque = boolean
            default:
                break
            }
        }
        return (backgroundColor, insets, opaque)
    }
    
    /// Return the dimensions values contained inside the traits array
    ///
    /// - parameter traits: a collection of traits
    ///
    /// - returns: a tuple with all dimension values
    public static func mapDimensionUnits(from traits:[ViewTraits])-> (height: DimensionUnit, width: DimensionUnit) {
        var height: DimensionUnit = 0
        var width: DimensionUnit = 0
        for trait in traits {
            switch trait {
            case let .height(unit):
                height = unit
            case let .width(unit):
                width = unit
            default:
                break
            }
        }
        return (height, width)
    }
}
