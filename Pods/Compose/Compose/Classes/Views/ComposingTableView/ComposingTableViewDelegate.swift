//
//  ComposingTableViewDelegate.swift
//  Compose
//
//  Created by Bruno Bilescky on 17/10/16.
//  Copyright © 2016 VivaReal. All rights reserved.
//

import UIKit

class ComposingTableViewDelegate: NSObject, UITableViewDelegate {

    let source: ComposingDataSource
    
    init(with source: ComposingDataSource) {
        self.source = source
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < source.state.endIndex else {
            return
        }
        let unit = source[indexPath.row]
        if let unit = unit as? TwoStepDisplayUnit {
            unit.beforeDisplay(view: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < source.state.endIndex else {
            return
        }
        let unit = source[indexPath.row]
        if let unit = unit as? TwoStepDisplayUnit {
            unit.afterDisplay(view: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let unit = source[indexPath.row]
        if let unit = unit as? SelectableUnit {
            unit.didSelect()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let unit = source[indexPath.row]
        let tableSize = tableView.frame.size
        return unit.heightUnit.value(for: tableSize)
    }
    
}
