//
//  TalkDetailViewController.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 18/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class TalkDetailViewController: UIViewController {

    @IBOutlet var detailView: TalkDetailView! {
        didSet {
            detailView.didTapGoBackCallback = { [unowned self] in
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    var talkToShow: TalkModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailView.state.talk = talkToShow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.detailView.state.talk = self.talkToShow
        }
    }
    

}
