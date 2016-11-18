//
//  SpeakerDetailViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakerDetailViewController: UIViewController {

    @IBOutlet var speakerDetailView: SpeakerDetailView! {
        didSet {
            speakerDetailView.closeCallback = self.closeCard
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var speakerToDisplay: SpeakerModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speakerDetailView.state.speaker = speakerToDisplay
    }
    
    func closeCard() {
        self.dismiss(animated: true, completion: nil)
    }

}
