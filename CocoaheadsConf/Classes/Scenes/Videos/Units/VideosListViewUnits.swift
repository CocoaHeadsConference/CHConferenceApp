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

    static func Videos(videos: [VideoModel], callback:((VideoModel)-> Void)?)-> ComposingUnit {
        let videosUnits = videos.map { Video(video: $0, callback: callback) }
        let container = CollectionStackUnit(identifier: "videos", traits: [.height(DimensionUnit(minusHeight: 132))], units: videosUnits) { collectionView in
            collectionView.lineSpace = 1
        }
        return container
    }
    
    static func Video(video: VideoModel, callback:((VideoModel)-> Void)?)-> ComposingUnit {
        let font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        let attributed = NSAttributedString(string: video.talk?.title ?? "", attributes: [NSFontAttributeName: font])
        let height = DimensionUnit { size in
            let reducedSize = CGSize(width: size.width - 32, height: size.height)
            let frame = attributed.boundingRect(with: reducedSize, options: .usesLineFragmentOrigin, context: nil)
            return max(52, frame.height + 32)
        }
        var unit = ViewUnit<UILabel>(id: "\(video.id)", traits: [.height(height), .insets(UIEdgeInsets(horizontal: 16))]) { label in
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
    
    static func Header()-> [ComposingUnit] {
        let spacer = ViewUnit<UIView>(id:"spacer", traits:[.height(20)]) { $0.backgroundColor = .white }
        let header = ViewUnit<UILabel>(id: "Header", traits: [.height(44)]) { label in
            label.superview?.backgroundColor = .white
            label.textColor = UIColor(hexString: "004D40")
            label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightBold)
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = "Vídeos"
        }
        return [spacer, header]
    }
    
    static func Empty()-> ComposingUnit {
        return ViewUnit<UILabel>(id: "NoVideo", traits: [ .height(DimensionUnit(minusHeight: 132)), .insets(UIEdgeInsets(horizontal: 16)) ]) { label in
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            label.numberOfLines = 0
            label.textAlignment = .center
            label.text = "Nenhum vídeo disponível no momento.\n As palestras serão adicionadas assim que for possível."
        }
    }
    
}
