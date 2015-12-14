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
    @IBOutlet weak var relatedVideosCollectionView: UICollectionView!
    
    var dict: NSDictionary? = nil
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var vidIndex: Int? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var brain: YoutubeBrain?
    
    func configureView() {        
        // Update the user interface for the detail item.
        if let index = self.vidIndex {
            if let label = self.detailDescriptionLabel {
                //label.text = detail.valueForKey("videoId")!.description#
                label.text = "Description"
                label.text = brain?.getTitleStringForIndex(index)
            }
        }
        
        if let player = self.playerView {
            if let index = self.vidIndex {
                //let videoId = detail.valueForKey("videoId")!.description
                playerView.delegate = self
                
                let videoId = brain?.getIdStringForIndex(index)
                
                //TODO closed captions?
                let playerVars: [NSObject: AnyObject] = ["autoplay" : 1, "rel" : 0, "enablejsapi" : 1, "autohide" : 1, "playsinline": 1, "modestbranding" : 1, "controls" : 1, "origin" : "https://www.example.com", "showinfo" : 0]
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
        
        let videoId = brain?.getIdStringForIndex(vidIndex!)
        
        print(videoId)
        
        //get search results... refactor to method if possible?
        brain!.getSearchResults("relatedToVideoId="+videoId!) { (response) in
            if let dictionary = response as NSDictionary? {
                self.dict = dictionary
                
                // print(self.dict)
                
                // we could also use dispatch_async here
                // http://stackoverflow.com/a/26262409/841052
                self.relatedVideosCollectionView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = relatedVideosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            flowLayout.itemSize = CGSize(width: relatedVideosCollectionView.frame.size.width / 3.0, height: relatedVideosCollectionView.frame.size.height / 3.0)
        } else {
            flowLayout.itemSize = CGSize(width: relatedVideosCollectionView.frame.size.width, height: relatedVideosCollectionView.frame.size.width * 9.0 / 16.0)
        }
        
        flowLayout.invalidateLayout()
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        return 1
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //does this return the correct number...
        
        if(dict != nil && dict!.count != 0){
            return dict!["items"]!.count <= 9 ? dict!["items"]!.count : 9
        }
        else {
            return 0
        }
        //return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // let cell = collectionView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        //let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        //self.configureCell(cell, atIndexPath: indexPath)
        //return cell
        
        let cell:VideoCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: VideoCell, atIndexPath indexPath: NSIndexPath) {
        
        print(indexPath.row)
        let titleString = brain!.getTitleStringForIndex(indexPath.row)
        
        cell.label.text = titleString
        
        let urlstring = brain!.getImageUrlForIndex(indexPath.row)
        print (urlstring)
        let url:NSURL = NSURL(string: urlstring)!
        
        if let dataVar:NSData = NSData(contentsOfURL:url){
            
            cell.image = UIImage(data: dataVar)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
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
    */
    
}

