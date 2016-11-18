//
//  ViewUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 05/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/** Generic Unit, that can encapsulate any UIView inside it. It uses [ComposingUnitCollectionViewCell](../Classes/ComposingUnitCollectionViewCell.html) as its CollectionViewCell if the inner view is not a UICollectionViewCell subclass.
    You can use it as : `let unit = ViewUnit<UILabel>() { label in }`
 */
public struct ViewUnit<View: UIView>: TypedUnit, SelectableUnit {
    
    typealias Cell = ComposingUnitCollectionViewCell<View>
    
    public let identifier: String
    public let heightUnit: DimensionUnit
    public let widthUnit: DimensionUnit
    
    /// ViewTraits that will be applied to the cell
    public let traits: [ViewTraits]
    
    /// select callback that will be invoked
    public var didSelectCallback: (() -> Void)?
    
    /// Callback that will configure the cell
    public let configureCallback: ((View)-> Void)
    
    /// Creates an ViewUnit with the given UIView type.
    public init(id identifier: String? = nil, traits: [ViewTraits] = [], configure:@escaping ((View)-> Void) = { _ in }) {
        if let identifier = identifier {
            self.identifier = identifier
        }
        else {
            self.identifier = UUID().uuidString
        }
        self.traits = traits
        self.configureCallback = configure
        let traitValues = ViewTraits.mapDimensionUnits(from: traits)
        self.heightUnit = traitValues.height
        self.widthUnit = traitValues.width
    }
    
    /// Checks for the cell type, if its an UICollectionViewCell subclass call directly, if subclass of `ComposingUnitCollectionViewCell`
    public func configure(view: UIView) {
        if let cell = view as? Cell {
            configure(cell: cell)
        }
        else if let view = view as? View {
            configure(innerView: view)
        }
        else {
            print("Wrong type for: {\(type(of:view))}")
        }
    }
    
    public func configure(innerView: View) {
        configureCallback(innerView)
    }
    
    private func configure(cell: Cell) {
        cell.backgroundColor = .clear
        cell.apply(traits: traits)
        configureCallback(cell.innerView)
    }
    
    /// Reuse identifier based on the cell type
    public func reuseIdentifier()-> String {
        let viewClass: AnyClass = View.self
        if let cellClass = viewClass as? UICollectionViewCell.Type {
            return cellClass.identifier()
        }
        return Cell.identifier()
    }
    
    /// Register inside collectionView
    public func register(in collectionView: UICollectionView) {
        let viewClass: AnyClass = View.self
        if let cellClass = viewClass as? UICollectionViewCell.Type {
            cellClass.register(in: collectionView)
        }
        else {
            Cell.register(in: collectionView)
        }
    }
    
    /// Select callback
    public func didSelect() {
        didSelectCallback?()
    }
    
}

