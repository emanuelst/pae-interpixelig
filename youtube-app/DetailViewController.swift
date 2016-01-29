//
//  DetailViewController.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/6/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DetailViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate, YTPlayerViewDelegate {
    
    var youtubeBrain = YoutubeBrain()
    
    @IBOutlet weak var detailDescriptionLabel: VideoLabel!
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var relatedVideosCollectionView: RDCollectionView!
    
    @IBOutlet weak var epicCollectionView: RDCollectionView!
    
    var dict: NSDictionary? = nil
    
    var videoId: String?
    
    // this could hold a videoObject some time...
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var vidIndex: Int? {
        didSet {
            // Update the view and videoId
            self.videoId = youtubeBrain.getIdStringForIndex(vidIndex!)
            self.configureView()
        }
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!){
        playerView.playVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureView()
        
        let layout = NodeLayout(itemWidth: relatedVideosCollectionView.frame.size.width / 3.0, itemHeight: 100, space: 1)
        self.relatedVideosCollectionView.collectionViewLayout = layout
        self.relatedVideosCollectionView.showsHorizontalScrollIndicator = false
        self.relatedVideosCollectionView.showsVerticalScrollIndicator = false
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        self.view.backgroundColor = UIColor.blackColor()
        // self.relatedVideosCollectionView.registerClass(VideoCell.self, forCellWithReuseIdentifier: "cell")
        self.relatedVideosCollectionView.reloadData()
    }
    
    func configureView() {
        // default value when starting app on iPad
        let video = videoId ?? "lG01rpkRRBw"
        
        // Update the user interface for the detail item.
        if let index = self.vidIndex {
            if let label = self.detailDescriptionLabel {
                //label.text = detail.valueForKey("videoId")!.description#
                label.text = "Description"
                label.text = youtubeBrain.getTitleStringForIndex(index) + "\n\n" + youtubeBrain.getDescriptionForIndex(index)
            }
        }
        
        if let player = self.playerView {
            //let videoId = detail.valueForKey("videoId")!.description
            playerView.delegate = self
            
            //TODO closed captions?
            let playerVars: [NSObject: AnyObject] = ["autoplay" : 1, "rel" : 0, "enablejsapi" : 1, "autohide" : 1, "playsinline": 1, "modestbranding" : 1, "controls" : 1, "origin" : "https://www.example.com", "showinfo" : 0]
            player.loadWithVideoId(video, playerVars: playerVars)
        }
        
        // get related
        youtubeBrain.getRelatedVideos(video) { (response) in
            if let dictionary = response as NSDictionary? {
                self.dict = dictionary
                
                // we could also use dispatch_async here
                // http://stackoverflow.com/a/26262409/841052
                self.relatedVideosCollectionView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // print(self.playerView.webView.frame)
        
        guard let flowLayout = relatedVideosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            flowLayout.itemSize = CGSize(width: relatedVideosCollectionView.frame.size.width / 3.0, height: relatedVideosCollectionView.frame.size.height / 3.0)
            
            (self.relatedVideosCollectionView.collectionViewLayout as! NodeLayout).setSizeTo(self.playerView.webView.frame.width, itemHeight: self.playerView.webView.frame.height, space: 0)
            
            // scroll to center
            let x = relatedVideosCollectionView.contentSize.width/2 - relatedVideosCollectionView.frame.size.width/2
            let y = relatedVideosCollectionView.contentSize.height/2 - relatedVideosCollectionView.frame.size.height/2
            
            self.relatedVideosCollectionView.setContentOffset(CGPoint(x: x, y: y), animated: false)

            
        } else {
            // scroll to top
            /*let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            
            if(relatedVideosCollectionView!.numberOfItemsInSection(0) > 0){
                relatedVideosCollectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
            }
            */
            
            // self.relatedVideosCollectionView.scrollToItemAtIndexPath(0, atScrollPosition: .Top , animated: true)
            flowLayout.itemSize = CGSize(width: relatedVideosCollectionView.frame.size.width, height: relatedVideosCollectionView.frame.size.width * 9.0 / 16.0)
        }
        flowLayout.invalidateLayout()
    }
    
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        if dict == nil { return 1 }
        if dict!["items"] == nil {return 1}
        
        return Int(floor(sqrt(Double(dict!["items"]!.count))))
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 20
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //does this return the correct number...
        if(dict != nil && dict!["items"] != nil && dict!.count != 0){
            return Int(floor(sqrt(Double(dict!["items"]!.count))))
        }
        else {
            return 0
        }
        //return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    //same function also in MasterViewController
    func configureCell(cell: VideoCell, atIndexPath indexPath: NSIndexPath) {

        let titleString = youtubeBrain.getTitleStringForIndex(indexPath.row)
        cell.inDetailView = true
        cell.label.text = titleString
        
        // add blur
        /*
        var visualEffectView = UIVisualEffectView()
        visualEffectView.effect = UIBlurEffect(style: .Light)
        visualEffectView.frame = cell.label.bounds
        cell.label.addSubview(visualEffectView)
        */
        
        let url:NSURL = NSURL(string: youtubeBrain.getImageUrlForIndex(indexPath.section*5 + indexPath.row))!
        cell.imageUrl = url
        
        // Image loading.
        // code from http://www.splinter.com.au/2015/09/24/swift-image-cache/
        if let image = url.cachedImage {
            // Cached: set immediately.
            cell.image = image
            cell.imageView.alpha = 1
        } else {
            // Not cached, so load then fade it in.
            cell.imageView.alpha = 1
            url.fetchImage { image in
                // Check the cell hasn't recycled while loading.
                cell.image = image
                cell.imageView.alpha = 0
                if cell.imageUrl == url {
                    cell.imageView.image = image
                    
                    UIView.animateWithDuration(0.3) {
                        cell.imageView.alpha = 1
                    }
                }
                
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.vidIndex = indexPath.row
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        playerView.pauseVideo()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if section == 2 {
            return UIEdgeInsetsMake(0, 0, 0,0)
        }
        
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
        
            let playerWidth = playerView.webView.frame.width
            let playerHeight = playerView.webView.frame.height
            
            let contentCenterX = relatedVideosCollectionView.contentSize.width/2
            let contentCenterY = relatedVideosCollectionView.contentSize.height/2
            
            let viewFrameSize = relatedVideosCollectionView.frame.size
            
            // ToDo: fix magic number
            let offsetX = relatedVideosCollectionView.contentOffset.x - relatedVideosCollectionView.frame.width / 2 - playerWidth/2
            let offsetY = relatedVideosCollectionView.contentOffset.y - relatedVideosCollectionView.frame.height / 2 - playerHeight/2 - 32.0
            
            let maxOffsetX = viewFrameSize.width/2 - playerWidth/2
            let maxOffsetY = viewFrameSize.height/2 - playerHeight/2
            
            print("offsetY: ", offsetY, " maxOffsetY: ", maxOffsetY)
            
            let maxedOffsetX = abs(offsetX) > maxOffsetX ? getSign(offsetX) * maxOffsetX : offsetX
            let maxedOffsetY = abs(offsetY) > maxOffsetY ? getSign(offsetY) * maxOffsetY : offsetY
        
            playerView.center = CGPointMake(contentCenterX-viewFrameSize.width/2 - maxedOffsetX - playerWidth/2, contentCenterY-viewFrameSize.height/2 - maxedOffsetY - playerHeight/2 - 32.0);
        }
        
        
    }
    
    func getSign(number: CGFloat) -> CGFloat {
        if number < 0 {
            return CGFloat(-1)
        } else {
            return CGFloat(1)
        }
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

