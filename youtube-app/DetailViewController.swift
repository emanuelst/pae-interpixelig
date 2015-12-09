//
//  DetailViewController.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/6/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailViewController: UIViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    //var detailItem: AnyObject? {
    //    didSet {
    //        // Update the view.
    //        self.configureView()
    //    }
    //}
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("landscape")
            self.navigationController?.hidesBarsWhenVerticallyCompact = true
            self.navigationController?.navigationBarHidden = true
        }
        
        
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                //label.text = detail.valueForKey("videoId")!.description#
                label.text = "Description"
            }
        }
        
        if let player = self.playerView {
            if let detail = self.detailItem {
                //let videoId = detail.valueForKey("videoId")!.description
                playerView.delegate = self

                let videoId = detailItem as! String
                
                let playerVars: [NSObject: AnyObject] = ["autoplay" : 1, "enablejsapi" : 1, "autohide" : 1, "playsinline": 1, "modestbranding" : 1, "controls" : 1, "origin" : "https://www.example.com", "showinfo" : 0]
                player.loadWithVideoId(videoId, playerVars: playerVars)
            }
            //let videoId = "enXT2jgB5bs"
        }
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!){
        print("ready")
        playerView.playVideo()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("landscape")
            self.navigationController?.hidesBarsWhenVerticallyCompact = true
            self.navigationController?.navigationBarHidden = true
        } else {
            print("portrait")
            self.navigationController?.hidesBarsWhenVerticallyCompact = true
            self.navigationController?.navigationBarHidden = false
        }
    }
    
    
}

