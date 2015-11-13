//
//  FirstViewController.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 11/12/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var searchResults: UITableView!
    @IBOutlet weak var search: UITextField!
    
    // TODO convert to class, e.g. "youtubeBrain"
    var jsonDict: NSDictionary = NSDictionary()
    var snippet: NSDictionary = NSDictionary()
    var loaded: Bool = false
    
    var rowNo = 0
    var key = "default"
    
    @IBAction func searchChanged(sender: AnyObject) {
        getSearchResults(search.text!)
        self.searchResults.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // api key
        var keys: NSDictionary?
        
        if let path = NSBundle.mainBundle().pathForResource("keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        key = keys?["youtubeApiKey"] as! String
        
        print(key)
        
        // load video in our player view
        let videoId = "enXT2jgB5bs"
        let playerVars: [String: Int] = ["playsinline": 1]
        
        playerView.loadWithVideoId(videoId, playerVars: playerVars)
        
        getSearchResults()
    
        // set tableview to our search results
        
        searchResults.delegate = self
        searchResults.dataSource = self

        //TODO get a search field ;)
        self.searchResults.reloadData()
    }
    
    
    // we assume we have a working internet connection
    // do a search, get results from url, parse and set dictionary
    // limited to ~500,000 per day!
    func getSearchResults(searchstring: String = "pratersauna") {
        //we only get video results
        //todo escape searchstring
        //var escapedString = searchstring.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    
        var url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(searchstring)&type=video&key=\(key)"
        
        var escape = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
        var nsurl = NSURL(string: escape!)
        let session = NSURLSession.sharedSession()
        // get JSON from URL and parse into dictionary
        var task = session.dataTaskWithURL(nsurl!) {
            (data, response, error) -> Void in
            
            do {
            self.jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
            } catch {
                //handle error
            }
            //print(jsonDict!["items"]!)
            //self.dictionary = jsonDict!["items"]! as! NSDictionary
            //use swifty json?
            //todo only request the needed datas
            /*
            for index in 0...4 {
                var id = jsonDict!["items"]![index]!["id"]! as! NSDictionary
                var snippet = jsonDict!["items"]![index]!["snippet"]! as! NSDictionary
                
                print(id["videoId"])
                print(snippet["title"])
            }
            */
            self.loaded=true
            self.searchResults.reloadData()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0
        if(loaded){
            number = jsonDict["items"]!.count
        }
        // return the correct number of rows for our picker
        return number
    }
    
    let textCellIdentifier = "TextCell"
    
    //TODO handle errors! (results < 5, ...)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = "default"
        cell.detailTextLabel?.text = "def detail"
        
        if(loaded){
            var text = self.jsonDict["items"]?[row]!["snippet"]! as! NSDictionary
            var id = jsonDict["items"]?[row]!["id"] as! NSDictionary
        
            cell.textLabel?.text = text["title"] as? String
            cell.detailTextLabel?.text = id["videoId"] as? String

            //print(text["title"])
            //valprint(id["id"])
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let playerVars: [String: Int] = ["playsinline": 1]

        var id = jsonDict["items"]?[row]!["id"] as! NSDictionary
        var vid = id["videoId"] as? String
        
        //print(row)

        playerView.loadWithVideoId(vid, playerVars: playerVars)
    }
}


