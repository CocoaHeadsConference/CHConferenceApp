//
//  SponsorsScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import SafariServices

class SponsorsScene: Scene {

    let name = "Patrocinadores"
    let initialViewController: UIViewController
    let rootViewController: SponsorsListViewController
    
    init(cache: Cache) {
        rootViewController = SponsorsListViewController(with: cache)
        initialViewController = UINavigationController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Patrocinadores", image: nil, tag: 0)
        rootViewController.didSelectSponsor = { [unowned self] sponsor in
            self.present(sponsor: sponsor)
        }
    }
    
    func present(sponsor: SponsorModel) {
        let safariViewController = SFSafariViewController(url: sponsor.url)
        rootViewController.present(safariViewController, animated: true, completion: nil)
    }
    
}
