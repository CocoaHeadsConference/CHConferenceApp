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
            speakerDetailView.backgroundColor = UIColor(hexString: "004D40")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var speakerToDisplay: SpeakerModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let talks = Cache.default.talks(for: speakerToDisplay)
        speakerDetailView.state = SpeakerDetailViewState(speaker: speakerToDisplay, talks: talks)
        
    }
    
    func closeCard() {
        self.dismiss(animated: true, completion: nil)
    }

}
