//
//  ComposingContainerDirection.swift
//  Compose
//
//  Created by Bruno Bilescky on 02/11/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Direction that collectionView will stack its units
public enum ComposingContainerDirection: Equatable {
    
    /// display units in a vertical orientation
    case vertical
    
    //Display units in a vertical orientation with {columns} items in each row
    case verticalGrid(columns: Int)
    
    /// display units in a horizontal orientation
    case horizontal
    
    //Display units in a horizontal orientation with {rows} items in each column
    case horizontalGrid(rows: Int)
    
    var divisor: Int {
        switch self {
        case .vertical: fallthrough
        case .horizontal:
            return 1
        case let .verticalGrid(number):
            return number
        case let .horizontalGrid(number):
            return number
        }
    }
    
    var collectionDirection: UICollectionViewScrollDirection {
        switch self {
        case .vertical, .verticalGrid:
            return .vertical
        case .horizontal, .horizontalGrid:
            return .horizontal
        }
    }
    
    public static func ==(lhs: ComposingContainerDirection, rhs: ComposingContainerDirection)-> Bool {
        switch (lhs, rhs) {
        case (.vertical, .vertical): return true
        case (.horizontal, .horizontal): return true
        case (.verticalGrid(let left), .verticalGrid(let right)) where left == right: return true
        case (.horizontalGrid(let left), .horizontalGrid(let right)) where left == right: return true
        case (.vertical, .verticalGrid(let columns)) where columns == 1: return true
        case (.verticalGrid(let columns), .vertical) where columns == 1: return true
        case (.horizontal, .horizontalGrid(let rows)) where rows == 1: return true
        case (.horizontalGrid(let rows), .horizontal) where rows == 1: return true
        default: return false
        }
    }
    
}
