//
//  LabelUnit.swift
//  Compose
//
//  Created by Bruno Bilescky on 16/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Sample unit, which display a text inside a UILabel
public struct LabelUnit: ComposingUnit, TwoStepDisplayUnit {

    typealias Cell = ComposingUnitCollectionViewCell<UILabel>
    
    let numberOfLines: Int
    let backgroundColor: UIColor
    let attributedText: NSAttributedString
    private let maxHeight: CGFloat
    public let identifier: String
    
    /// Common Init
    ///
    /// - parameter id:            this unit identifier
    /// - parameter text:          text that will be displayed
    /// - parameter font:          font to use
    /// - parameter color:         text color
    /// - parameter background:    cell background color
    /// - parameter numberOfLines: number of lines to use
    public init(id: String, text: String?, font: UIFont, color: UIColor, background: UIColor, maxHeight: CGFloat = -1, numberOfLines: Int = 0) {
        self.identifier = id
        self.maxHeight = maxHeight
        self.backgroundColor = background
        self.numberOfLines = numberOfLines
        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        self.attributedText = NSAttributedString(string: text ?? "", attributes: attributes)
        
    }
    
    /// Configure this UILabel with the given attributes
    ///
    /// - parameter view: the label to be configured
    public func configure(view: UIView) {
        guard let cell = view as? Cell else { return }
        cell.insets = UIEdgeInsets(horizontal: 16)
        cell.innerView.numberOfLines = self.numberOfLines
        cell.backgroundColor = backgroundColor
    }
    
    /// Called just before the view is displayed. Used to set the text that will be displayed
    ///
    /// - parameter view: label to configure
    public func beforeDisplay(view: UIView) {
        guard let cell = view as? Cell else { return }
        cell.innerView.attributedText = self.attributedText
    }
    
    /// Dynamic height based on the font, number of lines and text
    public var heightUnit: DimensionUnit {
        return DimensionUnit { size in
            let options: NSStringDrawingOptions = self.numberOfLines != 1 ? .usesLineFragmentOrigin : []
            let fitRect = self.attributedText.boundingRect(with: size, options: options, context: nil)
            let textHeight = fitRect.height + 4
            if self.maxHeight < 0 {
                return textHeight
            }
            else {
                return min(self.maxHeight, textHeight)
            }
            
        }
    }
    
    /// Dynamic width based on the font, number of lines and text
    public var widthUnit: DimensionUnit {
        return 0
    }
    
    /// Cell reuse identifier
    public func reuseIdentifier() -> String {
        return Cell.identifier()
    }
    
    /// Register inside collectionView
    public func register(in collectionView: UICollectionView) {
        Cell.register(in: collectionView)
    }
    
}
