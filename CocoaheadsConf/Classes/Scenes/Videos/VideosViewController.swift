//
//  VideosViewController.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController {

    let cache: Cache
    
    var listView: VideosListView? {
        return self.view as? VideosListView
    }
    
    var didSelectVideoCallback: ((VideoModel)-> Void)?
    
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
        self.view = VideosListView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Vídeos"
        listView?.didSelectVideoCallback = { [unowned self] video in
            self.didSelectVideoCallback?(video)
        }
        self.updateList()
    }
    
    func updateList() {
        listView?.state.videos = cache.videos.flatMap({ $0.1 })
            .filter({ $0.talk != nil })
            .sorted(by: { $0.talk!.id < $1.talk!.id })
    }

}
