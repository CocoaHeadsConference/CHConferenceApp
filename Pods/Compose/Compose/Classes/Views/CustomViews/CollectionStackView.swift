//
//  CollectionStackView.swift
//  Compose
//
//  Created by Bruno Bilescky on 05/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

public typealias State = (()->[ComposingUnit])

/**
 Specialized Container Stack with an inside CollectionView
 */
@IBDesignable
open class CollectionStackView: UIView {

    /// CollectionView that will be displayed
    public let container = ComposingCollectionView()
    
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
        self.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        let toView = self
        let itemView = container
        let leadingConstraint = NSLayoutConstraint(item: itemView, attribute: .leading, relatedBy: .equal, toItem: toView, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: itemView, attribute: .top, relatedBy: .equal, toItem: toView, attribute: .top, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: itemView, attribute: .trailing, relatedBy: .equal, toItem: toView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: itemView, attribute: .bottom, relatedBy: .equal, toItem: toView, attribute: .bottom, multiplier: 1, constant: 0)
        toView.addConstraints([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
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
