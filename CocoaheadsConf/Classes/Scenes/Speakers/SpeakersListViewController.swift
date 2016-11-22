//
//  SpeakersListViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakersListViewController: UIViewController {

    @IBOutlet var listView: SpeakerListView! {
        didSet {
            listView.backgroundColor = UIColor(hexString: "004D40")
            listView.displayCallback = self.displayDetail(for:)
        }
    }
    
    var displaySpeakerCallback: ((SpeakerModel, UIViewController)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Palestrantes"
        listView.state.speakers = Array(Cache.default.speakers.values).sorted(by: { (first, second) -> Bool in
            return first.name.compare(second.name) == .orderedAscending
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVc = segue.destination as? SpeakerDetailViewController,
            let speaker = sender as? SpeakerModel {
            detailVc.speakerToDisplay = speaker
        }
    }

    func displayDetail(for speaker: SpeakerModel) {
        displaySpeakerCallback?(speaker, self)
    }
    
}
