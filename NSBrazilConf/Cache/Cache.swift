//
//  Cache.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import LLVS

class Cache: NSObject {

    private static let FeedValueId = Value.ID("HOME_FEED_CACHE")
    private var currentVersion: Version? = nil
    
    private lazy var cacheStore: LLVS.Store? = {
        guard let rootDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let store = try? LLVS.Store(rootDirectoryURL: URL(fileURLWithPath: rootDir, isDirectory: true))
        do {
            try store?.reloadHistory()
        } catch {
            print("Failed to load cache history: \(error.localizedDescription)")
        }
        self.currentVersion = store?.mostRecentHead
        return store
    }()
    
    public func loadCache() -> Data? {
        guard let store = self.cacheStore else {
            return nil
        }
        
        guard let version = self.currentVersion else {
            return nil
        }
        
        let value: Value? = try? store.value(id: Cache.FeedValueId, at: version.id)
        return value?.data
    }
    
    public func saveCache(_ data: Data) {
        guard let store = self.cacheStore else {
            return
        }
        
        let value = Value(id: Cache.FeedValueId, data: data)
        if let currentVersion = self.currentVersion {
            self.currentVersion = try? store.makeVersion(basedOnPredecessor: currentVersion.id, storing: [.update(value)])
        } else {
            self.currentVersion = try? store.makeVersion(basedOnPredecessor: nil, storing: [.insert(value)])
        }
    }
    
}
