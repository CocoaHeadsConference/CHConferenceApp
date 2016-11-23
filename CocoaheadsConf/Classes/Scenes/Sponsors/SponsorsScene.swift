//
//  SponsorsScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct SponsorsScene: Scene {

    let name = "Patrocinadores"
    let initialViewController: UIViewController
    let rootViewController: SponsorsListViewController
    
    init(cache: Cache) {
        rootViewController = SponsorsListViewController(with: cache)
        initialViewController = UINavigationController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Patrocinadores", image: nil, tag: 0)
    }
    
}
