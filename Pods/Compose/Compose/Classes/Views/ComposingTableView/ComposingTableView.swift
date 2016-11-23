//
//  ComposingTableView.swift
//  Compose
//
//  Created by Bruno Bilescky on 17/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// TableView used to display units.
@IBDesignable
public class ComposingTableView: UITableView, ComposingContainer {

    public var direction: ComposingContainerDirection {
        get {
            return .vertical
        }
        set {
            fatalError("there is only one direction to TableView")
        }
    }
    
    private let internalSource = ComposingDataSource(initialState: [])
    
    private lazy var composeDataSource: ComposingTableViewDataSource = ComposingTableViewDataSource(with: self.internalSource)
    private lazy var composeDelegate: ComposingTableViewDelegate = ComposingTableViewDelegate(with: self.internalSource)

    private lazy var stateChangeDiff: TableViewDiffCalculator<String> = {
        let diff = TableViewDiffCalculator<String>(tableView: self)
        diff.finishReorderingCallback = { set in
            self.didFinishReorderingItems(changedSet: set)
        }
        return diff
    }()
    
    /// Current state. On each update here we will use each's unit identifier and add/remove/update cell with animation
    public var state: [ComposingUnit] = [] {
        didSet {
            let identifiers = state.map { unit in
                return unit.identifier
            }
            stateChangeDiff.updateSource(with: identifiers) { [unowned self] in
                self.internalSource.state = self.state
            }
        }
    }
    
    /// Select animation behavior for inserting new items to the array
    public var insertionAnimation: UITableViewRowAnimation {
        get {
            return stateChangeDiff.insertionAnimation
        }
        set {
            stateChangeDiff.insertionAnimation = newValue
        }
    }
    
    /// Select animation behavior for deleting new items to the array
    public var deletionAnimation: UITableViewRowAnimation {
        get {
            return stateChangeDiff.deletionAnimation
        }
        set {
            stateChangeDiff.deletionAnimation = newValue
        }
    }
    
    /// Convenience init that uses .zero frame and default style
    public convenience init() {
        self.init(frame: .zero)
    }
    
    /// Convenience init that uses the plain style
    ///
    /// - parameter frame: initial view frame
    public convenience init(frame: CGRect) {
        self.init(frame: frame, style: .plain)
    }
    
    /// Default init
    ///
    /// - parameter frame:  initial view frame
    /// - parameter style: tableView Style
    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    /// Init that unwrap from Interface builder.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.dataSource = composeDataSource
        self.delegate = composeDelegate
    }
    
    private func didFinishReorderingItems(changedSet: Set<Int>) {
        let cellsWithIndexPath: [(UITableViewCell, Int)] = self.visibleCells.flatMap { cell in
            guard let indexPath = self.indexPath(for: cell), !changedSet.contains(indexPath.row) else { return nil }
            return (cell, indexPath.item)
        }
        let cellsWithUnits: [(UITableViewCell, ComposingUnit)] = cellsWithIndexPath.flatMap { (cell, index) in
            return (cell, self.internalSource[index])
        }
        cellsWithUnits.forEach { (cell, unit) in
            unit.configure(view: cell)
        }
    }
    
}
