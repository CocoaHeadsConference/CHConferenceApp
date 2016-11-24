//
//  Scene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

protocol Scene {
    
    var initialViewController: UIViewController { get }
    
}

extension Scene {
    
    func startWithWindow(window: UIWindow) {
        window.rootViewController = self.initialViewController
        if !window.isKeyWindow {
            window.makeKeyAndVisible()
        }
    }
    
}
