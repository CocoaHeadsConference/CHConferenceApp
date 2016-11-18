//
//  ComposingCollectionView.swift
//  Compose
//
//  Created by Bruno Bilescky on 04/10/16.
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

/// CollectionView used to display units.
@IBDesignable
public class ComposingCollectionView: UICollectionView, ComposingContainer {

    /// Direction to stack units inside this collectionView
    public var direction: ComposingContainerDirection {
        get {
            return composeDelegate.direction
        }
        set {
            if composeDelegate.direction != newValue {
                composeDelegate.direction = newValue
                self.performBatchUpdates({ 
                    (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = newValue.collectionDirection
                })
            }
        }
    }
    
    /// Current state. On each update here we will use each's unit identifier and add/remove/update cell with animation
    public var state: [ComposingUnit] = [] {
        didSet {
            let identifiers = state.map { $0.identifier }
            stateChangeDiff.updateSource(with: identifiers) { [unowned self] in
                self.internalSource.state = self.state
            }
        }
    }
    
    /// Inset applied to each section in the collectionView
    public var sectionInset: UIEdgeInsets {
        get {
            precondition(self.collectionViewLayout is UICollectionViewFlowLayout, "Only works for UICollectionViewFlowLayout")
            return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
        }
        set {
            precondition(self.collectionViewLayout is UICollectionViewFlowLayout, "Only works for UICollectionViewFlowLayout")
            (self.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset = newValue
        }
    }
    
    /// Space applied between items in the collection
    public var itemSpace: CGFloat {
        get {
            precondition(self.collectionViewLayout is UICollectionViewFlowLayout, "Only works for UICollectionViewFlowLayout")
            return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0.0
        }
        set {
            precondition(self.collectionViewLayout is UICollectionViewFlowLayout, "Only works for UICollectionViewFlowLayout")
            (self.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = newValue
        }
    }
    
    /// Space applied between lines in the collectionView
    public var lineSpace: CGFloat {
        get {
            precondition(self.collectionViewLayout is UICollectionViewFlowLayout, "Only works for UICollectionViewFlowLayout")
            return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0.0
        }
        set {
            precondition(self.collectionViewLayout is UICollectionViewFlowLayout, "Only works for UICollectionViewFlowLayout")
            (self.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = newValue
        }
    }
    
    public var scrollDidChangeCallback: ((CGFloat)-> Void)? {
        get {
            return composeDelegate.scrollDidChangeCallback
        }
        set {
            composeDelegate.scrollDidChangeCallback = newValue
        }
    }
    
    private let internalSource = ComposingDataSource(initialState: [])
    
    private lazy var composeDataSource: ComposingCollectionViewDataSource = ComposingCollectionViewDataSource(with: self.internalSource)
    private lazy var composeDelegate: ComposingCollectionViewDelegate = ComposingCollectionViewDelegate(with: self.internalSource)
    
    private lazy var stateChangeDiff: CollectionViewDiffCalculator<String> = {
        let diff = CollectionViewDiffCalculator<String>(collectionView: self)
        diff.finishReorderingCallback = self.didFinishReorderingItems(changedSet:)
        return diff
    }()
    
    /// Convenience init that uses .zero frame and default layout
    public convenience init() {
        self.init(frame: .zero)
    }
    
    /// Convenience init that uses the default layout
    ///
    /// - parameter frame: initial view frame
    public convenience init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.init(frame: frame, collectionViewLayout: layout)
    }
    
    /// Default init
    ///
    /// - parameter frame:  initial view frame
    /// - parameter layout: initial view layout
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    /// Init that unwrap from Interface builder. Will override the view layout to the default type
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let layout = UICollectionViewFlowLayout()
        self.collectionViewLayout = layout
        commonInit()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dataSource = composeDataSource
        self.delegate = composeDelegate
    }

    private func didFinishReorderingItems(changedSet: Set<Int>) {
        self.visibleCells.flatMap { cell in
            guard let indexPath = self.indexPath(for: cell), !changedSet.contains(indexPath.item) else { return nil }
            return (cell, indexPath.item)
        }.map { (cell, index) in
            return (cell, self.internalSource.state[index])
        }.forEach { (cell, unit) in
            unit.configure(view: cell)
        }
    }
    
}
