//
//  CollectionStackContainerCollectionViewCell.swift
//  Compose
//
//  Created by Bruno Bilescky on 26/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

class CollectionStackContainerCollectionViewCell: UICollectionViewCell {
    
    private var currentConstraints: [NSLayoutConstraint] = []
    
    public private(set) var innerView: ComposingCollectionView
    
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    var containerSize: CGSize {
        get {
            return CGSize(width: widthConstraint.constant, height: heightConstraint.constant)
        }
        set {
            widthConstraint.constant = newValue.width
            heightConstraint.constant = newValue.height
        }
    }
    
    override public init(frame: CGRect) {
        self.innerView = ComposingCollectionView(frame: frame)
        super.init(frame: frame)
        commonInit(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported.")
    }
    
    private func commonInit(frame: CGRect) {
        self.isOpaque = false
        self.backgroundColor = .clear
        self.innerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(innerView)
        self.addConstraints()
    }
    
    private func addConstraints() {
        widthConstraint = NSLayoutConstraint(item: self.innerView, attribute: .width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        heightConstraint = NSLayoutConstraint(item: self.innerView, attribute: .height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        self.innerView.addConstraints([widthConstraint, heightConstraint])
    }
    
}
