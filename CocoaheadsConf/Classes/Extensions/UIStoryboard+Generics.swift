//
//  UIStoryboard+Generics.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

extension UIStoryboard {

    func firstViewController<VC: UIViewController>()-> VC {
        guard let firstVC = self.instantiateInitialViewController() else {
            fatalError("there was no initial View Controller in this storyboard \(self)")
        }
        if let navigationController = firstVC as? UINavigationController {
            guard let rootVC = navigationController.viewControllers.first as? VC else {
                fatalError("There was no view controller of type \(VC.self) inside navigation controller")
            }
            return rootVC
        }
        guard let viewController = firstVC as? VC else {
            fatalError("Initial view controller  was of type \(type(of: firstVC)) instead of type \(VC.self)")
        }
        return viewController
    }
    
}
