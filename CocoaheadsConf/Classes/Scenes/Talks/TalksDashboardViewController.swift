//
//  TalksDashboardViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalksDashboardViewController: UIViewController {

    var listView: TalksDashboardView? {
        return self.view as? TalksDashboardView
    }
    
    var cache: Cache
    var displayTalkCallback: ((TalkModel)-> Void)?
    
    init(with cache: Cache) {
        self.cache = cache
        super.init(nibName: nil, bundle: nil)
        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.cache = Cache.default
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        self.view = TalksDashboardView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = Theme.shared.mainColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Atividades"
        self.navigationController?.tabBarItem = UITabBarItem(title: "Atividades", image: #imageLiteral(resourceName: "schedule"), tag: 0)
        
        let typeSelector = UISegmentedControl(items: ["Todas", "Palestras", "Workshops"])
        typeSelector.tintColor = .white
        typeSelector.selectedSegmentIndex = 0
        typeSelector.addTarget(self, action: #selector(self.updateFromSegmentedControl(segmentedControl:)), for: .valueChanged)
        self.navigationItem.titleView = typeSelector
        listView?.didSelectTalkCallback = displayTalkCallback
        updateListState()
    }
    
    func updateListState() {
        listView?.state.talks = Array(cache.talks.values)
    }
    
    
    @objc func updateFromSegmentedControl(segmentedControl: UISegmentedControl) {
        listView?.changeTalkDisplayType(segmentedControl: segmentedControl)
    }

}
