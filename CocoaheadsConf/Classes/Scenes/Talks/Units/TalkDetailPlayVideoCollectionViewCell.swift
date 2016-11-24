//
//  TalkDetailPlayVideoCollectionViewCell.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalkDetailPlayVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var playButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var videoButtonCallback: (() -> Void)?
    
    @IBAction func startPlaying() {
        videoButtonCallback?()
        playButton.isHidden = true
        spinner.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.spinner.stopAnimating()
            self.playButton.setTitle(NSLocalizedString("Continuar Assistindo", comment: "Continue Watching - button title to continue watching a video"), for: .normal)
            self.playButton.isHidden = false
        }
    }
    
}
