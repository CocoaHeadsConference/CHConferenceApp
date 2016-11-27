//
//  MainScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct MainScene<NF: NetworkFetcher>: Scene, CacheUpdatable {
    
    let name = "Main"
    
    let scenesToDisplay: [Scene]
    let networkFetcher: NF
    let mainViewController: MainTabController
    let initialViewController: UIViewController
    
    init(with scenes:[Scene], networkFetcher: NF = NF(cacheService: Cache.default)) {
        self.scenesToDisplay = scenes
        self.networkFetcher = networkFetcher
        mainViewController = MainTabController()
        mainViewController.setViewControllers(scenesToDisplay.map{ $0.initialViewController }, animated: false)
        initialViewController = mainViewController
    }
    
    func fetchNewData() {
        self.networkFetcher.fetchNewInfo {
            self.updateFromCache()
            self.scenesToDisplay.forEach({ scene in
                if let cachableScene = scene as? CacheUpdatable {
                    cachableScene.updateFromCache()
                }
            })
        }
    }
    
    func updateFromCache() {
        mainViewController.tabBar.barTintColor = Theme.shared.mainColor
        mainViewController.tabBar.tintColor = Theme.shared.contrastingColor
        mainViewController.tabBar.unselectedItemTintColor = Theme.shared.shadowColor.withAlphaComponent(0.8)
    }
    
}
