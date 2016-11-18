//
//  SpeakersScene.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 04/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

struct SpeakersScene: Scene {

    let name = "Palestrantes"
    let storyboard = UIStoryboard(name: "Speakers", bundle: nil)
    let initialViewController: UIViewController
    let rootViewController: SpeakersListViewController
    
    init() {
        rootViewController = storyboard.firstViewController()
        initialViewController = NavigationViewController(rootViewController: rootViewController)
        initialViewController.tabBarItem = UITabBarItem(title: "Palestrantes", image: nil, tag: 0)
        rootViewController.displaySpeakerCallback = self.displayDetail(for: in:)
    }
    
    func displayDetail(for speaker: SpeakerModel, in viewController: UIViewController) {
        viewController.performSegue(withIdentifier: "showDetail", sender: speaker)
    }
    
}
