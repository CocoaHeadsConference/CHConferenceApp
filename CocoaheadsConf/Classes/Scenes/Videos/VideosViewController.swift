//
//  VideosViewController.swift
//  CocoaheadsConf
//
//  Created by Guilherme Rambo on 23/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController {

    fileprivate struct Storyboard {
        static let cell = "videoCell"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var videos: [VideoModel] = [] {
        didSet {
            guard isViewLoaded else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(hexString: "004D40")
        tableView.separatorColor = UIColor(hexString: "006654")
        tableView.separatorInset = .zero
        tableView.indicatorStyle = .white
    }
    
    func updateList() {
        videos = Cache.default.videos.flatMap({ $0.1 })
            .filter({ $0.talk != nil })
            .sorted(by: { $0.talk!.id < $1.talk!.id })
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndex = tableView.indexPathForSelectedRow else { return }
        guard let detailViewController = segue.destination as? TalkDetailViewController else { return }
        
        let video = videos[selectedIndex.row]
        detailViewController.talkToShow = video.talk
    }

}

extension VideosViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cell, for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        let video = videos[indexPath.row]
        cell.textLabel?.text = video.talk!.title
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor(hexString: "004D40")
        
        return cell
    }
    
}
