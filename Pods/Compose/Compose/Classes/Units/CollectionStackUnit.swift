//
//  CollectionStackUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 06/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Unit that can contains other units inside it.
/// You can specify a direction for these internal items to follow
public struct CollectionStackUnit: ComposingUnit, ContainerUnit, TwoStepDisplayUnit {
    
    typealias Cell = CollectionStackContainerCollectionViewCell
    
    public let identifier: String
    /// The direction that this cell will render it's children units
    public let direction: ComposingContainerDirection
    
    /// Children units that will be rendered inside this cell
    public let units: [ComposingUnit]
    private var customHeight: DimensionUnit
    private var customWidth: DimensionUnit
    private var customBackgroundColor: UIColor
    private var configureCallback: ((ComposingCollectionView)-> Void)
    
    /// Creates a unit with the given identifier, direction, traits and closure that can generate its items
    ///
    /// - returns: the unit that can be added to any container
    public init(identifier: String? = nil, direction: ComposingContainerDirection = .vertical, traits: [ViewTraits], units: [ComposingUnit], configure:@escaping ((ComposingCollectionView)-> Void) = { _ in }) {
        if let identifier = identifier {
            self.identifier = identifier
        }
        else {
            self.identifier = UUID().uuidString
        }
        self.configureCallback = configure
        self.direction = direction
        self.units = units
        let styles = ViewTraits.mapStyle(from: traits)
        self.customBackgroundColor = styles.backgroundColor
        let dimensions = ViewTraits.mapDimensionUnits(from: traits)
        self.customHeight = dimensions.height
        self.customWidth = dimensions.width
    }
    
    public func configure(view: UIView) {
        guard let cell = view as? Cell else { return }
        cell.backgroundColor = .clear
        cell.innerView.backgroundColor = customBackgroundColor
        cell.innerView.direction = direction
        configureCallback(cell.innerView)
        cell.innerView.state = units
    }
    
    public func beforeDisplay(view: UIView) {
        guard let cell = view as? Cell else { return }
        let cellWidth = view.superview!.frame.width
        let cellHeight = min(cell.frame.height, cell.superview!.frame.height)
        cell.containerSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    public func scrollviewFrom(view: UIView)-> UIScrollView {
        guard let cell = view as? Cell else { fatalError("we should have a \(Cell.self) here, but got \(type(of: view))") }
        return cell.innerView
    }
    
    public func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    public func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
    public var heightUnit: DimensionUnit {
        switch self.direction {
        case .horizontal, .horizontalGrid:
            return customHeight
        case .vertical:
            return DimensionUnit { size in
                let height = self.units.reduce(CGFloat(0.0), { (total, unit) -> CGFloat in
                    return total + unit.heightUnit.value(for: size)
                })
                return height
            }
        case let .verticalGrid(columns):
            return DimensionUnit { size in
                let chunks = stride(from: 0, to: self.units.count, by: columns).map {
                    Array(self.units[$0..<min($0 + columns, self.units.count)])
                }
                let height = chunks.reduce(0.0) { (total, row)-> CGFloat in
                    return total + row.reduce(0.0) { (biggest, unit)-> CGFloat in
                        let height = floor(unit.heightUnit.value(for: size))
                        return max(height, biggest)
                    }
                }
                return height
            }
        }
    }
    
    public var widthUnit: DimensionUnit {
        switch self.direction {
        case .vertical, .verticalGrid:
            return customWidth
        case .horizontal:
            return DimensionUnit { size in
                let width = self.units.reduce(CGFloat(0.0), { (total, unit) -> CGFloat in
                    return total + unit.widthUnit.value(for: size)
                })
                return min(width, size.width)
            }
        case let .horizontalGrid(rows):
            return DimensionUnit { size in
                let chunks = stride(from: 0, to: self.units.count, by: rows).map {
                    Array(self.units[$0..<min($0 + rows, self.units.count)])
                }
                let width = chunks.reduce(0.0) { (total, column)-> CGFloat in
                    return total + column.reduce(0.0) { (biggest, unit)-> CGFloat in
                        let width = floor(unit.widthUnit.value(for: size))
                        return max(width, biggest)
                    }
                }
                return width
            }
        }
    }
    
}
