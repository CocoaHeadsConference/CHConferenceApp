//
//  ComposingTableViewDataSource.swift
//  Compose
//
//  Created by Bruno Bilescky on 17/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

class ComposingTableViewDataSource: NSObject, UITableViewDataSource {

    let source: ComposingDataSource
    
    init(with source: ComposingDataSource) {
        self.source = source
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.numberOfUnits()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let unit = source[indexPath.row]
        let reuseIdentifier = unit.reuseIdentifier()
        if source.needsRegister(identifier: reuseIdentifier) {
            unit.register(in: tableView)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        unit.configure(view: cell)
        return cell
    }
    
}
