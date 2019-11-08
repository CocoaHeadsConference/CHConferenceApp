//
//  Cache.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class Cache: NSObject {

    private static let CacheFileID = "FEED_DATA_CACHE"
    private lazy var cachePath: URL? = {
        guard let rootDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let basePath = URL(fileURLWithPath: rootDir, isDirectory: true)
        let fullPath = basePath.appendingPathComponent(Cache.CacheFileID, isDirectory: false)
        return fullPath
    }()
    
    let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func loadCache() -> Data? {
        guard let cachePath = self.cachePath else {
            return nil
        }
        guard let data = try? Data(contentsOf: cachePath) else {
            return nil
        }
        return Data(base64Encoded: data)
    }
    
    public func saveCache(_ data: Data) {
        guard let cachePath = self.cachePath else {
            return
        }
        let dataToStore = data.base64EncodedData()
        do {
            try dataToStore.write(to: cachePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Error on storying cache: \(error.localizedDescription)")
        }
    }
    
}
