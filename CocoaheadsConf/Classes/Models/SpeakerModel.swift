//
//  SpeakerModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Marshal

struct SpeakerModel: Unmarshaling {
    
    private static let serverURL: URL = URL(string:"http://cocoaheadsconference.com.br")!
    
    let id: Int
    let name: String
    let headline: String
    let citation: String
    let bio: String
    let twitterHandle: String
    let linkedInHandle: String
    let githubHandle: String
    let imageHandle: String
    
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        name = try object.value(for: "name")
        headline = try object.value(for: "title")
        bio = try object.value(for: "bio")
        citation = try object.value(for: "citation")
        imageHandle = try object.value(for: "image")
        
        twitterHandle = try object.value(for: "twitterHandle")
        linkedInHandle = try object.value(for: "linkedinHandler")
        githubHandle = try object.value(for: "githubHandler")
    }
    
    var imageURL: URL {
        return SpeakerModel.serverURL.appendingPathComponent(imageHandle)
    }
    
}
