//
//  TalkDetailViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 18/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalkDetailViewController: UIViewController {

    var detailView: TalkDetailView? {
        return self.view as? TalkDetailView
    }
    
    var talkToShow: TalkModel
    
    init(for talk: TalkModel) {
        self.talkToShow = talk
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = TalkDetailView(frame: UIScreen.main.bounds)
        detailView?.container.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        detailView?.didTapPlayCallback = { [unowned self] in
            guard let video = self.talkToShow.video else { return }
            
            PlaybackHelper(with: video).play(from: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailView?.state.talk = self.talkToShow
        self.title = self.talkToShow.type.title
    }
    

}
