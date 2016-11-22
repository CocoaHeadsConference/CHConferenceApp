//
//  TalksDashboardViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalksDashboardViewController: UIViewController {

    @IBOutlet var listView: TalksDashboardView?
    
    var displayTalkCallback: ((TalkModel)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CocoaheadsBR"
        self.navigationController?.tabBarItem = UITabBarItem(title: "Palestras", image: nil, tag: 0)
        listView?.didSelectTalkCallback = displayTalkCallback
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateListState()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? TalkDetailViewController,
            let talk = sender as? TalkModel else { return }
        viewController.talkToShow = talk
    }
    
    func updateListState() {
        if let listView = listView {
            listView.state.talks = Array(Cache.default.talks.values)
        }
    }
    

}
