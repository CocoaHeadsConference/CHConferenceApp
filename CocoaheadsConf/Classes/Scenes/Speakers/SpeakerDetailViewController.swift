//
//  SpeakerDetailViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 14/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakerDetailViewController: UIViewController {

    var speakerDetailView: SpeakerDetailView? {
        return self.view as? SpeakerDetailView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let speakerToDisplay: SpeakerModel
    let cache: Cache

    init(with speaker: SpeakerModel, cache: Cache) {
        self.speakerToDisplay = speaker
        self.cache = cache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = SpeakerDetailView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detalhes"
        let talks = cache.talks(for: speakerToDisplay)
        speakerDetailView?.state = SpeakerDetailViewState(speaker: speakerToDisplay, talks: talks)
        
    }

}
