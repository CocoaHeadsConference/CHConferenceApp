//
//  SFSafariViewController+URL.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 26/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

extension UIViewController {
    func open(url: URL, failure: (title: String, message: String)? = nil) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: failure?.title, message: failure?.message)
        }
    }
    
    func showAlert(title: String?, message: String?) {
        var finalTitle = "Atenção"
        var finalMessage = "Não foi possível abrir o link desejado."
        
        if let ttl = title,
        let msg = message {
            finalTitle = ttl
            finalMessage = msg
        }
        
        let alertController = UIAlertController(title: finalTitle, message: finalMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
