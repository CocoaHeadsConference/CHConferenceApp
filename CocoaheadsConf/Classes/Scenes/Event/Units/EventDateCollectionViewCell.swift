//
//  EventDateCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class EventDateCollectionViewCell: UICollectionViewCell {

    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    
    @IBOutlet var startContainerView: UIView!
    @IBOutlet var endContainerView: UIView!
    
    private let formatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM \n EEEE"
        return formatter
    }()
    
    var startDate: Date? {
        didSet {
            guard let date = startDate else {
                startDateLabel.text = nil
                return
            }
            startDateLabel.attributedText = attributedText(from: date)
        }
    }
    
    var endDate: Date? {
        didSet {
            guard let date = endDate else {
                endDateLabel.text = nil
                return
            }
            endDateLabel.attributedText = attributedText(from: date)
        }
    }
    
    private func attributedText(from date: Date)-> NSAttributedString {
        formatter.dateFormat = "dd MMM"
        let attributed = NSMutableAttributedString(string: formatter.string(from: date), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 26, weight: UIFontWeightMedium)])
        formatter.dateFormat = "\nEEEE"
        let subline = NSAttributedString(string: formatter.string(from: date), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)])
        attributed.append(subline)
        return attributed
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startContainerView.layer.cornerRadius = 4
        endContainerView.layer.cornerRadius = 4
        let borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        startContainerView.layer.borderColor = borderColor
        endContainerView.layer.borderColor = borderColor
        startContainerView.layer.borderWidth = 1
        endContainerView.layer.borderWidth = 1
    }
    

}
