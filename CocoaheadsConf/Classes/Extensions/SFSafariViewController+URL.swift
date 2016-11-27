//
//  SFSafariViewController+URL.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import SafariServices

extension SFSafariViewController {

    static func display(url: URL, from viewController:UIViewController) {
        let safariViewController = SFSafariViewController(url: url)
        viewController.present(safariViewController, animated: true, completion: nil)
    }
    
}
