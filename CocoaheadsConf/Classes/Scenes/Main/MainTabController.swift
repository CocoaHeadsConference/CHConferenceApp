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
        self.tabBar.barTintColor = UIColor(hexString: "004D40")
        self.tabBar.tintColor = .white
    }

}
