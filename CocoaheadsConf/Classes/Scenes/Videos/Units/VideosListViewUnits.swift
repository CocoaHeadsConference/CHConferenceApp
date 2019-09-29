//
//  VideosListViewUnits.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

struct VideosListViewUnits {

    static func Video(video: VideoModel, callback:((VideoModel)-> Void)?)-> ComposingUnit {
        let font = UIFont.systemFont(ofSize: 15, weight: .medium)
        let attributed = NSAttributedString(string: video.talk?.title ?? "", attributes: [ .font: font])
        var unit = ViewUnit<UILabel>(id: "\(video.id)", traits: [.height(80), .insets(UIEdgeInsets(horizontal: 16))]) { label in
            label.attributedText = attributed
            label.numberOfLines = 0
            label.superview?.backgroundColor = TalkModel.TalkType.talk.backgroundColor
            label.textColor = .white
        }
        unit.didSelectCallback = {
            callback?(video)
        }
        return unit
    }
    
    static func Empty()-> ComposingUnit {
        return EmptyUnit(identifier: "NoVideo", text: "Nenhum vídeo disponível no momento.\n As palestras serão adicionadas assim que for possível.")
    }
    
}
