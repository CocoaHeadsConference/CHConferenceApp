//
//  SpeakersListViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakersListViewController: UIViewController {

    let cache: Cache
    
    var listView: SpeakerListView? {
        return self.view as? SpeakerListView
    }
    
    var displaySpeakerCallback: ((SpeakerModel)-> Void)?
    
    init(with cache: Cache) {
        self.cache = cache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.cache = Cache.default
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        self.view = SpeakerListView(frame: UIScreen.main.bounds)
        listView?.displayCallback = self.displayDetail(for:)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Palestrantes"
        listView?.state.speakers = Array(cache.speakers.values).sorted(by: { (first, second) -> Bool in
            return first.name.compare(second.name) == .orderedAscending
        })
    }

    func displayDetail(for speaker: SpeakerModel) {
        displaySpeakerCallback?(speaker)
    }
    
}
