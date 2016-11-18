//
//  TableStackView.swift
//  Compose
//
//  Created by Bruno Bilescky on 19/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/**
 Specialized Container Stack with an inside TableView
 */
open class TableStackView: UIView {
    
    /// CollectionView that will be displayed
    public let container = ComposingTableView()
    
    /// Convenience init that set view frame to zero
    convenience public init() {
        self.init(frame: .zero)
    }
    
    /// Common init with frame value
    ///
    /// - parameter frame: view initial frame value
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Common init with wrapped content.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        container.backgroundColor = .clear
        self.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": container]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:[], metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:[], metrics:nil, views: bindings))
    }
    
    /// IBDesignable method, called to display this view inside Interface Builder
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    /// methodo that take a closure to update the internal collectionView state.
    ///
    /// - parameter state: closure that will produce the new state
    public func updateWith(state: State) {
        let unitsFromState = state()
        self.container.state = unitsFromState
    }
    
}
