//
//  SpeakersScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SpeakersScene: Scene {

    let cache: Cache
    let initialViewController: UIViewController
    let rootViewController: SpeakersListViewController
    
    init(cache: Cache) {
        self.cache = cache
        rootViewController = SpeakersListViewController(with: self.cache)
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Palestrantes", image: nil, tag: 0)
        rootViewController.displaySpeakerCallback = { [unowned self] speaker in
            let viewController = self.viewController(for: speaker)
            self.rootViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
    func viewController(for speaker: SpeakerModel)-> SpeakerDetailViewController {
        return SpeakerDetailViewController(with: speaker, cache: cache)
    }
    
}
