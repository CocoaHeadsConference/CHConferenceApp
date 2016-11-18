//
//  UITableViewCell+Extensions.swift
//  Compose
//
//  Created by Bruno Bilescky on 25/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

/// Register UITableViewCell in UITableView
extension UITableViewCell {

    /// Try to find a nib for this TableViewCell. If it finds one, register it to the tableView, else it register the class itself
    ///
    /// - parameter tableView: tableView to register
    public static func register(in tableView: UITableView, customIdentifier: String? = nil) {
        let identifier = customIdentifier ?? self.identifier()
        if let nib = nibForSelf() {
            tableView.register(nib, forCellReuseIdentifier: identifier)
        }
        else {
            tableView.register(self, forCellReuseIdentifier: identifier)
        }
    }
    
}
