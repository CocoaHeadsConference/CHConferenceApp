//
//  ErrorController.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 03/11/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import WatchKit
import SwiftUI

class ErrorController: WKHostingController<ErrorView> {
    
    var error: Error?
    
    override func awake(withContext context: Any?) {
        guard let error = context as? Error else { return }
        self.error = error
    }
    
    override var body: ErrorView {
        return ErrorView(error: error!)
    }
    
}
