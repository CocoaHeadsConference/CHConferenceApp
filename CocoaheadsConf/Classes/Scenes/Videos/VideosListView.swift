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
    
}


func ComposeVideosListView(with state: VideoListViewState, callback:((VideoModel)-> Void)?)-> [ComposingUnit] {
    var units: [ComposingUnit] = []
    units.add {
        return VideosListViewUnits.Header()
    }
    
    units.add(if: !state.videos.isEmpty) {
        return VideosListViewUnits.Videos(videos: state.videos, callback: callback)
    }
    
    units.add(if: state.videos.isEmpty) {
        return VideosListViewUnits.Empty()
    }
    return units
}
