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
    
    let video: VideoModel
    
    init(with video: VideoModel) {
        self.video = video
    }
    
    private var moviePlayer: AVPlayerViewController = {
        let p = AVPlayerViewController()
        
        p.allowsPictureInPicturePlayback = true
        p.updatesNowPlayingInfoCenter = true
        
        return p
    }()
    
    func play(from controller: UIViewController) {
        Youtube.h264videosWithYoutubeURL(video.youTubeUrl) { info, error in
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
        
        var timeObserver: Any!
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(5, timeScale), queue: nil) { time in
            guard let duration = player.currentItem?.duration else { return }
            
            let position = CMTimeGetSeconds(time)
            
            if position >= CMTimeGetSeconds(duration) - 30 {
                // reached end of video - 30 seconds: reset position
                UserDefaults.standard.set(position: -1, in: self.video.id)
                player.removeTimeObserver(timeObserver)
            } else {
                // update position
                UserDefaults.standard.set(position: Float(position), in: self.video.id)
            }
        }
        
        controller.present(self.moviePlayer, animated: true) {
            let savedPosition = UserDefaults.standard.position(in: self.video.id)
            
            if savedPosition > 0 {
                player.seek(to: CMTimeMakeWithSeconds(Float64(savedPosition), timeScale))
            }
            
            player.play()
        }
    }
    
}
