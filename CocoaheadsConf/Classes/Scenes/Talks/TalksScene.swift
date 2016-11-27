//
//  TalksScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalksScene: Scene, CacheUpdatable {
    
    let cache: Cache
    let initialViewController: UIViewController
    let rootViewController: TalksDashboardViewController
    
    init(cache: Cache) {
        self.cache = cache
        rootViewController = TalksDashboardViewController(with: self.cache)
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Atividades", image: #imageLiteral(resourceName: "schedule"), tag: 0)
        rootViewController.displayTalkCallback = { [unowned self] talk in
            let viewController = self.viewController(for: talk)
            self.rootViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func viewController(for talk: TalkModel)-> TalkDetailViewController {
        let viewController = TalkDetailViewController(for: talk)
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
    
    func updateFromCache() {
        rootViewController.navigationController?.navigationBar.barTintColor = Theme.shared.mainColor
        rootViewController.updateListState()
    }
    
    
}
