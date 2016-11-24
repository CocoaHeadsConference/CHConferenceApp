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
    let videoId: Int
    
    init(with url: URL, id: Int) {
        self.videoUrl = url
        self.videoId = id
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
            
            if let videoURLString = info?["url"] as? String,
                let url = URL(string: videoURLString) {
                DispatchQueue.main.async {
                    self.setupAndPlay(url, from: controller)
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
    
    private func setupAndPlay(_ videoUrl: URL, from controller: UIViewController) {
        let player = AVPlayer(url: videoUrl)
        
        self.moviePlayer.player = player
        
        let timeScale = Int32(NSEC_PER_SEC)
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(5, timeScale), queue: nil) { time in
            let position = Float(CMTimeGetSeconds(time))
            UserDefaults.standard.set(position: position, in: self.videoId)
            NSLog("Time: \(position)")
        }
        
        controller.present(self.moviePlayer, animated: true) {
            let savedPosition = UserDefaults.standard.position(in: self.videoId)
            player.seek(to: CMTimeMakeWithSeconds(Float64(savedPosition), timeScale))
            player.play()
        }
    }
    
}
