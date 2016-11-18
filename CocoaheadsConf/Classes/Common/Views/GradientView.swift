//
//  GradientView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var upperColor: UIColor = UIColor(white: 0, alpha: 0) {
        didSet {
            updateGradient()
        }
    }
    @IBInspectable var bottomColor: UIColor = UIColor(white: 0, alpha: 0.8) {
        didSet {
            updateGradient()
        }
    }
    
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        gradientLayer.frame = self.bounds
        gradientLayer.opacity = 0.8
        self.layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    private func updateGradient() {
        gradientLayer.colors = [upperColor.cgColor, bottomColor.cgColor]
    }

}
