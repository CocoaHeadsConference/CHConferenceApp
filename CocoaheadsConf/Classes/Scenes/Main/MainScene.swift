//
//  MainScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct MainScene<NF: NetworkFetcher>: Scene {
    
    let name = "Main"
    
    let scenesToDisplay: [Scene]
    let networkFetcher: NF
    let initialViewController: UIViewController
    
    init(with scenes:[Scene], networkFetcher: NF = NF(cacheService: Cache.default)) {
        self.scenesToDisplay = scenes
        self.networkFetcher = networkFetcher
        let viewController = MainTabController()
        viewController.setViewControllers(scenesToDisplay.map{ $0.initialViewController }, animated: false)
        initialViewController = viewController
    }
    
    func fetchNewData() {
        self.networkFetcher.fetchNewInfo {
            self.scenesToDisplay.forEach({ scene in
                if let cachableScene = scene as? CacheUpdatable {
                    cachableScene.updateFromCache()
                }
            })
        }
    }
    
}
