//
//  VideosScene.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class VideosScene: Scene, CacheUpdatable {
    
    let name = "Vídeos"
    let initialViewController: UIViewController
    let rootViewController: VideosViewController
    
    init(cache: Cache, talksScene: TalksScene) {
        rootViewController = VideosViewController(with: cache)
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Vídeos", image: #imageLiteral(resourceName: "videos"), tag: 0)
        rootViewController.didSelectVideoCallback = { [unowned self] video in
            guard let talk = video.talk else { return }
            let viewController = talksScene.viewController(for: talk)
            self.rootViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func updateFromCache() {
        rootViewController.navigationController?.navigationBar.barTintColor = Theme.shared.mainColor
        rootViewController.updateList()
    }
    
    
}
