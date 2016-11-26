//
//  DisplayTwitterHelper.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import SafariServices

class DisplayTwitterHelper {

    private init() {
        
    }
    
    static func display(twitter: String, from viewController:UIViewController) {
        guard let url = URL(string:"https://twitter.com/\(twitter)") else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        viewController.present(safariViewController, animated: true, completion: nil)
    }
    
}
