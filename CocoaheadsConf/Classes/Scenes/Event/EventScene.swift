//
//  EventScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 25/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class EventScene: Scene, CacheUpdatable {
    
    let cache: Cache
    let initialViewController: UIViewController
    let rootViewController: EventMainViewController
    
    init(cache: Cache) {
        self.cache = cache
        rootViewController = EventMainViewController(with: self.cache)
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Evento", image: #imageLiteral(resourceName: "icon-event"), tag: 0)
        rootViewController.didTapTwitterCallback = { [unowned self] event in
            self.displayTwitter(for: event)
        }
    }
    
    func displayTwitter(for event: EventModel) {
        DisplayTwitterHelper.display(twitter: event.twitterHandle, from: rootViewController)
    }
    
    func updateFromCache() {
        rootViewController.updateListState()
    }

}
