//
//  MainTabController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = Theme.shared.mainColor
        self.tabBar.tintColor = Theme.shared.contrastingColor
        self.tabBar.unselectedItemTintColor = Theme.shared.shadowColor.withAlphaComponent(0.8)
    }

}
