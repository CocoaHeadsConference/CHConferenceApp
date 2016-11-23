//
//  PlaybackHelper.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import YoutubeSourceParserKit

struct PlaybackHelper {
    
    private enum PlaybackError: Error {
        case urlNotFound
    }
    
    let videoUrl: URL
    
    init(with url: URL) {
        self.videoUrl = url
    }
    
    private var moviePlayer: AVPlayerViewController = {
        let p = AVPlayerViewController()
        
        p.allowsPictureInPicturePlayback = true
        p.updatesNowPlayingInfoCenter = true
        
        return p
    }()
    
    func play(from controller: UIViewController) {
        Youtube.h264videosWithYoutubeURL(videoUrl) { info, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.show(error!, from: controller)
                }
                return
            }
            
            if let videoURLString = info?["url"] as? String {
                DispatchQueue.main.async {
                    let player = AVPlayer(url: URL(string: videoURLString)!)
                    self.moviePlayer.player = player
                    controller.present(self.moviePlayer, animated: true) {
                        player.play()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.show(PlaybackError.urlNotFound, from: controller)
                }
            }
        }
    }
    
    private func show(_ error: Error, from controller: UIViewController) {
        let alert = UIAlertController(
            title: "Não foi possível reproduzir o vídeo",
            message: "Desculpe, não podemos exibir esse vídeo neste momento. Tente mais tarde.\n\(error)",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        controller.present(alert, animated: true, completion: nil)
    }
    
}
