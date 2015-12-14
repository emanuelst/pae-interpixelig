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
        youtubeBrain.getSearchResults("q="+enteredText!) { (response) in
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
        
        // self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        // self.navigationItem.rightBarButtonItem = addButton
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: "moveCursorToSearch:")
        self.navigationItem.rightBarButtonItem = searchButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // load video in our player view
        // let videoId = "enXT2jgB5bs"
        // let playerVars: [String: Int] = ["playsinline": 1]
        
        // playerView.loadWithVideoId(videoId, playerVars: playerVars)
        youtubeBrain.initKeys()
        //youtubeBrain.getSearchResults()
        
        /*
        youtubeBrain.getSearchResults() { (response) in
        if let dictionary = response as NSDictionary? {
        self.dict = dictionary
        
        // we could also use dispatch_async here
        // http://stackoverflow.com/a/26262409/841052
        self.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
        }
        }
        */
        
    }
    
    /* from https://github.com/mnbayan/autoCompleteTextFieldSwift */
    
    private func configureTextField(){
        autoCompleteTextField.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        autoCompleteTextField.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)
        autoCompleteTextField.autoCompleteCellHeight = 35.0
        autoCompleteTextField.maximumAutoCompleteCount = 20
        autoCompleteTextField.hidesWhenSelected = true
        autoCompleteTextField.hidesWhenEmpty = true
        autoCompleteTextField.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        autoCompleteTextField.autoCompleteAttributes = attributes
    }
    
    //todo... similar code as in youtubeBrain (url connection, json decoding)
    private func handleTextFieldInterfaces(){
        autoCompleteTextField.onTextChange = {[weak self] text in
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
            
            self!.youtubeBrain.getSearchResults("q="+self!.autoCompleteTextField.autoCompleteStrings![indexpath.row]) { (response) in
                if let dictionary = response as NSDictionary? {
                    self!.dict = dictionary
                    
                    // we could also use dispatch_async here
                    // http://stackoverflow.com/a/26262409/841052
                    self!.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                }
            }
        }
        
        autoCompleteTextField.onTextFieldShouldReturn = {[weak self] text in
            self!.youtubeBrain.getSearchResults("q="+text) { (response) in
                if let dictionary = response as NSDictionary? {
                    self!.dict = dictionary
                    
                    // we could also use dispatch_async here
                    // http://stackoverflow.com/a/26262409/841052
                    self!.collectionView?.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
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
    
    /*
    func insertNewObject(sender: AnyObject, videoId: String, title: String) {
    let context = self.fetchedResultsController.managedObjectContext
    let entity = self.fetchedResultsController.fetchRequest.entity!
    let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    newManagedObject.setValue(videoId, forKey: "videoId")
    newManagedObject.setValue(title, forKey: "title")
    
    // Save the context.
    do {
    try context.save()
    } catch {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //print("Unresolved error \(error), \(error.userInfo)")
    abort()
    }
    }*/
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.collectionView?.indexPathsForSelectedItems() {
                //let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                // controller.detailItem = object
                controller.brain = youtubeBrain
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
        else{
            
            //
            // let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
            
            // cell.textLabel!.text = object.valueForKey("title")!.description
            // cell.textLabel!.text = titleString
            
            
            print(indexPath.row)
            let titleString = youtubeBrain.getTitleStringForIndex(indexPath.row)
            
            cell.label.text = titleString
            
            
            let urlstring = youtubeBrain.getImageUrlForIndex(indexPath.row)
            print (urlstring)
            let url:NSURL = NSURL(string: urlstring)!
            
            if let dataVar:NSData = NSData(contentsOfURL:url){
                
                let yOffset:CGFloat = ((collectionView!.contentOffset.y - cell.frame.origin.y) / 200) * 25
                cell.imageOffset = CGPointMake(0, yOffset)
                
                cell.image = UIImage(data: dataVar)
            }
            
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
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Video", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "videoId", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    /*
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
    self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
    self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    default:
    return
    }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
    self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    }
    }
    */
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //self.tableView.endUpdates()
    }
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
}

