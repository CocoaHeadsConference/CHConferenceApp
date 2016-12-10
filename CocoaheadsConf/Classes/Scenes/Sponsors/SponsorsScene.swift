//
//  SponsorsScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class SponsorsScene: Scene, CacheUpdatable {

    let name = "Patrocinadores"
    let initialViewController: UIViewController
    let rootViewController: SponsorsListViewController
    
    init(cache: Cache) {
        rootViewController = SponsorsListViewController(with: cache)
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Patrocinadores", image: #imageLiteral(resourceName: "sponsors"), tag: 0)
        rootViewController.didSelectSponsor = { [unowned self] sponsor in
            self.present(sponsor: sponsor)
        }
    }
    
    func updateFromCache() {
        rootViewController.navigationController?.navigationBar.barTintColor = Theme.shared.mainColor
    }
    
    func present(sponsor: SponsorModel) {
        rootViewController.open(url: sponsor.url, failureTitle: "Atenção", failureMessage: "Não foi possível abrir o link desejado")
    }
    
}
