//
//  EventMainViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class EventMainViewController: UIViewController {

    let cache: Cache
    
    var eventView: EventMainView? {
        return self.view as? EventMainView
    }
    
    var didTapSafariCallback: ((URL)-> Void)?
    
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
        self.view = EventMainView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateListState()
    }
    

    func updateListState() {
        guard let event = cache.event else {
            return
        }
        self.eventView?.didTapSafariCallback = { [unowned self] url in
            self.didTapSafariCallback?(url)
        }
        self.title = event.name
        self.navigationController?.tabBarItem.title = "Evento"
        self.eventView?.state.event = event
        self.eventView?.backgroundColor = Theme.shared.mainColor
    }
    
}
