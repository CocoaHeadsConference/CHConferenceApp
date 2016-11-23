//
//  VideosScene.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct VideosScene: Scene, CacheUpdatable {
    
    let name = "Vídeos"
    let storyboard = UIStoryboard(name: "Videos", bundle: nil)
    let initialViewController: UIViewController
    let rootViewController: VideosViewController
    
    init() {
        rootViewController = storyboard.firstViewController()
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Vídeos", image: nil, tag: 0)
    }
    
    func updateFromCache() {
        rootViewController.updateList()
    }
    
    
}
