//
//  NavigationViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 09/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.tintColor = .white
        self.navigationBar.barTintColor = Theme.shared.mainColor
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage(color: Theme.shared.mainColor)
        self.navigationBar.titleTextAttributes = [.foregroundColor: Theme.shared.contrastingColor]
    }
    

}
