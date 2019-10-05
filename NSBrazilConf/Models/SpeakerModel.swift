//
//  SpeakerModel.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 07/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct SpeakerModel: Codable, Identifiable {
    
    private static let serverURL: URL = URL(string:"http://cocoaheadsconference.com.br")!
    
    let id: Int
    let name: String
    let headline: String
    let citation: String
    let bio: String
    let twitterHandle: String?
    let linkedInHandle: String?
    let githubHandle: String?
    let image: String

    var imageURL: URL {
        return SpeakerModel.serverURL.appendingPathComponent(image)
    }
    
}
