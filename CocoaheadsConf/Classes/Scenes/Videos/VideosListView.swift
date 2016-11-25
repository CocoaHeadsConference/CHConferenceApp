//
//  VideosListView.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import Compose

class VideosListView: CollectionStackView {

    var state = VideoListViewState(videos: []) {
        didSet {
            self.container.state = ComposeVideosListView(with: state, callback: didSelectVideoCallback)
        }
    }

    var didSelectVideoCallback: ((VideoModel)-> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Theme.shared.mainColor
        container.lineSpace = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


func ComposeVideosListView(with state: VideoListViewState, callback:((VideoModel)-> Void)?)-> [ComposingUnit] {
    var units: [ComposingUnit] = []
    units.add {
        let videosUnits = state.videos.map { VideosListViewUnits.Video(video: $0, callback: callback) }
        return videosUnits
    }
    
    units.add(if: state.videos.isEmpty) {
        return VideosListViewUnits.Empty()
    }
    return units
}
