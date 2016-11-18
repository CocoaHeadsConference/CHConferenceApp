//
//  TalksScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct TalksScene: Scene, CacheUpdatable {
    
    let name = "Palestras"
    let storyboard = UIStoryboard(name: "Talks", bundle: nil)
    let initialViewController: UIViewController
    let rootViewController: TalksDashboardViewController
    
    init() {
        rootViewController = storyboard.firstViewController()
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Palestras", image: nil, tag: 0)
    }
    
    func updateFromCache() {
        rootViewController.updateListState()
    }
    
}
