//
//  FeedManager.swift
//  NSBrazilConfWatchApp WatchKit Extension
//
//  Created by Leonardo Oliveira on 03/11/19.
//  Copyright © 2019 Cocoaheadsbr. All rights reserved.
//

import WatchKit
import Combine

class FeedManager {
    
    static var shared = FeedManager()
    
    var dataTask: AnyCancellable?
    
    let url = URL(string: "https://nsbrazil.com/app/2019-schedule.json")!
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private init() {}
    
    func fetchSchedule() {
        let session = URLSession.shared
        self.dataTask = session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: NSBrazilData.self, decoder: decoder)
            .sink(receiveCompletion: { (completion) in
                session.finishTasksAndInvalidate()
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        WKInterfaceController.reloadRootPageControllers(withNames: ["ErrorController"], contexts: [error], orientation: .horizontal, pageIndex: 0)
                    }
                case .finished: break
                }
            }, receiveValue: { (data) in
                guard let feeds = data.schedule.first?.feeds else {
                    return
                }
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(withNames: Array<String>(repeating: "FeedController", count: feeds.count), contexts: feeds, orientation: .horizontal, pageIndex: 0)
                }
            })
    }
    
}
