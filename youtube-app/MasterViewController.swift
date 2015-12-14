//
//  MasterViewController.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/6/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate {
    
    var youtubeBrain = YoutubeBrain()
    
    @IBOutlet weak var autoCompleteTextField: AutoCompleteTextField!
    
    private var responseData:NSMutableData?
    // private var selectedPointAnnotation:MKPointAnnotation?
    private var connection:NSURLConnection?
    
    private let baseURLString = "https://suggestqueries.google.com/complete/search"
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    //the blur biew
    var visualEffectView : UIVisualEffectView!
    
    var dict: NSDictionary? = nil
    
    func moveCursorToSearch(sender: AnyObject) {
        autoCompleteTextField.becomeFirstResponder()
    }
    
    //TODO we might want to add an overlay or button to exit out of the "search mode"
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let enteredText = textField.text
        print(enteredText)
        textField.resignFirstResponder();
        
        //get search results... refactor to method if possible?
        youtubeBrain.getSearchResults(enteredText!) { (response) in
            if let dictionary = response as NSDictionary? {
                self.dict = dictionary
                
                // we could also use dispatch_async here
                // http://stackoverflow.com/a/26262409/841052
                self.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
            }
        }
        
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        autoCompleteTextField.delegate = autoCompleteTextField
        
        configureTextField()
        handleTextFieldInterfaces()
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "moveCursorToSearch:")
        self.navigationItem.rightBarButtonItem = searchButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // add blur view
        // addBlur()
        
        // load video in our player view
        // let videoId = "enXT2jgB5bs"
        // let playerVars: [String: Int] = ["playsinline": 1]
        
        // playerView.loadWithVideoId(videoId, playerVars: playerVars)
        youtubeBrain.initKeys()
        
        
        // initialize with ”default" videos
        // we can later change this to e.g popular videos in country
        youtubeBrain.getSearchResults() { (response) in
            if let dictionary = response as NSDictionary? {
                self.dict = dictionary
                
                // we could also use dispatch_async here
                // http://stackoverflow.com/a/26262409/841052
                self.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
            }
        }
    }
    
    func addBlur(){
        let blurEffect: UIBlurEffect = UIBlurEffect(style: .Light)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        // frame is calculated in didLayoutSubviews
        // visualEffectView.frame = self.collectionView!.bounds
        self.collectionView!.addSubview(visualEffectView)
        
        // add touch recognizer
        let gesture = UITapGestureRecognizer(target: self, action: "removeBlur")
        self.visualEffectView.addGestureRecognizer(gesture)
        
    }
    
    func removeBlur(){
        visualEffectView.removeFromSuperview()
        autoCompleteTextField.endEditing(true)
        //dismiss keyboard & put cursor out of textField
        //autoCompleteTextField.resignFirstResponder()
    }
    
    func scrollToTop(){
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        //fix parallax offsets
    }
    
    /* from https://github.com/mnbayan/autoCompleteTextFieldSwift */
    
    private func configureTextField(){
        autoCompleteTextField.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autoCompleteTextField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        autoCompleteTextField.autoCompleteCellHeight = 35.0
        autoCompleteTextField.maximumAutoCompleteCount = 20
        autoCompleteTextField.hidesWhenSelected = true
        autoCompleteTextField.hidesWhenEmpty = true
        autoCompleteTextField.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 14.0)
        autoCompleteTextField.autoCompleteAttributes = attributes
    }
    
    //todo... similar code as in youtubeBrain (url connection, json decoding)
    private func handleTextFieldInterfaces(){
        
        autoCompleteTextField.onTextFieldDidBeginEditing = {[weak self] text in
            self!.performSelectorOnMainThread(Selector("addBlur"), withObject: nil, waitUntilDone: true)
        }
        
        
        autoCompleteTextField.onTextChange = {[weak self] text in
            
            //if theres no blur onTextChange, we add one
            if !self!.collectionView!.subviews.contains(self!.visualEffectView){
                print("it does contain one")
                self!.performSelectorOnMainThread(Selector("addBlur"), withObject: nil, waitUntilDone: true)
            }
            
            if !text.isEmpty{
                if self!.connection != nil{
                    self!.connection!.cancel()
                    self!.connection = nil
                }
                
                let urlString = "\(self!.baseURLString)?client=firefox&ds=yt&q=\(text)"
                
                //let url = NSURL(string: (urlString as NSString).stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!)
                
                let url = NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                
                let session = NSURLSession.sharedSession()
                
                // get JSON from URL and parse into dictionary
                let task = session.dataTaskWithURL(url!) {
                    (data, response, error) -> Void in
                    
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        
                        let suggestionList = result[1] as! NSArray
                        
                        var suggestionArray = [String]()
                        
                        for suggestion in suggestionList {
                            print(suggestion)
                            suggestionArray.append(suggestion as! String)
                        }
                        
                        self!.autoCompleteTextField.autoCompleteStrings = suggestionArray
                        return
                        
                    } catch {
                        //handle error
                    }
                    
                    
                }
                task.resume()
                
            }
        }
        
        autoCompleteTextField.onSelect = {[weak self] text, indexpath in
            //TODO display spinner on our collectionView
            let selectedSuggestion = self!.autoCompleteTextField.autoCompleteStrings![indexpath.row]
            print(selectedSuggestion)
            
            self?.autoCompleteTextField.text = selectedSuggestion
            
            self!.youtubeBrain.getSearchResults(self!.autoCompleteTextField.autoCompleteStrings![indexpath.row]) { (response) in
                if let dictionary = response as NSDictionary? {
                    self!.dict = dictionary
                    
                    // we could also use dispatch_async here
                    // http://stackoverflow.com/a/26262409/841052
                    self!.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                    self!.performSelectorOnMainThread(Selector("removeBlur"), withObject: nil, waitUntilDone: true)
                    self!.performSelectorOnMainThread(Selector("scrollToTop"), withObject: nil, waitUntilDone: true)

                    
                }
            }
        }
        
        autoCompleteTextField.onTextFieldShouldReturn = {[weak self] text in
            self!.youtubeBrain.getSearchResults(text) { (response) in
                if let dictionary = response as NSDictionary? {
                    self!.dict = dictionary
                    
                    // we could also use dispatch_async here
                    // http://stackoverflow.com/a/26262409/841052
                    self!.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                    self!.performSelectorOnMainThread(Selector("removeBlur"), withObject: nil, waitUntilDone: true)
                    self!.performSelectorOnMainThread(Selector("scrollToTop"), withObject: nil, waitUntilDone: true)
                }
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.collectionView?.indexPathsForSelectedItems() {
                //let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                // controller.detailItem = object
                controller.youtubeBrain = self.youtubeBrain
                // todo --> pass vid id instead or create a video object...
                // todo --> we can create a video object (for description, id and title), pass our brain and get comments via the vid Id !
                // first selected object...
                controller.vidIndex = indexPath.first?.row
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //does this return the correct number...
        
        if(dict != nil && dict!.count != 0){
            return dict!["items"]!.count
        }
        else {
            return 0
        }
        //return sectionInfo.numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // let cell = collectionView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        //let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        //self.configureCell(cell, atIndexPath: indexPath)
        //return cell
        
        let cell:VideoCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        for view in collectionView!.visibleCells(){
            let view:VideoCell = view as! VideoCell
            let yOffset:CGFloat = ((collectionView!.contentOffset.y - view.frame.origin.y) / 200) * 25
            view.setImageOffset(CGPointMake(0, yOffset))
        }
    }
    
    
    func configureCell(cell: VideoCell, atIndexPath indexPath: NSIndexPath) {
        if(dict == nil && dict!.count == 0){
            cell.label.text = "xxx"
            
        }
        else {
            let titleString = youtubeBrain.getTitleStringForIndex(indexPath.row)
            
            cell.label.text = titleString
            
            let url:NSURL = NSURL(string: youtubeBrain.getImageUrlForIndex(indexPath.row))!
            cell.imageUrl = url
            
            // Image loading.
            // code from http://www.splinter.com.au/2015/09/24/swift-image-cache/
            if let image = url.cachedImage {
                // Cached: set immediately.
                cell.imageView.image = image
                cell.imageView.alpha = 1
            } else {
                // Not cached, so load then fade it in.
                cell.imageView.alpha = 0
                url.fetchImage { image in
                    // Check the cell hasn't recycled while loading.
                    if cell.imageUrl == url {
                        cell.imageView.image = image
                        UIView.animateWithDuration(0.3) {
                            cell.imageView.alpha = 1
                        }
                    }
                }
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            flowLayout.itemSize = CGSize(width: self.collectionView!.frame.size.width / 2.0, height: self.collectionView!.frame.size.width / 4.0)
        } else {
            flowLayout.itemSize = CGSize(width: self.collectionView!.frame.size.width, height: self.collectionView!.frame.size.width / 2.0)
        }
    }
    
    
    //MARK: NSURLConnectionDelegate
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        responseData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if let data = responseData{
            
            do{
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                
                let suggestionList = result[1] as! NSArray
                
                var suggestionArray = [String]()
                
                for suggestion in suggestionList {
                    print(suggestion)
                    suggestionArray.append(suggestion as! String)
                }
                
                self.autoCompleteTextField.autoCompleteStrings = suggestionArray
                return
            }
            catch let error as NSError{
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
    }
    
    //TODO this fixes our search results for now
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let enteredText = autoCompleteTextField.text
        //get search results... refactor to method if possible?
        youtubeBrain.getSearchResults(enteredText!) { (response) in
            if let dictionary = response as NSDictionary? {
                self.dict = dictionary
                
                // we could also use dispatch_async here
                // http://stackoverflow.com/a/26262409/841052
                self.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // set frame for visual effect view
        guard let effectView = visualEffectView as UIVisualEffectView? else {
            return
        }
        
        effectView.frame = self.collectionView!.bounds
    }
    
    // todo: when starting in landscape, initalize correctly...
    // todo, move this functionality to --> AutoCompleteTextField.swift?
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.autoCompleteTextField.autoCompleteTableWidth = size.width
    }
    
}

