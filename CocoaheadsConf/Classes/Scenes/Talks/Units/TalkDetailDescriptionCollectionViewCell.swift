//
//  TalkDetailDescriptionCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 21/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalkDetailDescriptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var videoButton: UIButton! {
        didSet {
            videoButton.addTarget(self, action: #selector(videoButtonAction(_:)), for: .touchUpInside)
        }
    }
    
    var videoButtonCallback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func videoButtonAction(_ sender: Any?) {
        videoButtonCallback?()
        
        videoButton.isHidden = true
        spinner.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.spinner.stopAnimating()
            self.videoButton.isHidden = false
        }
    }

}
