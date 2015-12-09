//
//  youtubeBrain.swift
//  youtube-app
//
//  Created by Emanuel Stadler on 12/6/15.
//  Copyright © 2015 University of Vienna. All rights reserved.
//

import Foundation

class YoutubeBrain{
    
    // default api key…
    var key = "default"
    
    // TODO convert to class, e.g. "youtubeBrain" - BRAAAAAAINS!!!
    var jsonDict: NSDictionary = NSDictionary()
    var snippet: NSDictionary = NSDictionary()
    var loaded: Bool = false
    
    // setup dummy data... should this go into viewDidLoad?
    
    func initKeys(){
        // get api key
        var keys: NSDictionary?
        
        if let path = NSBundle.mainBundle().pathForResource("keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        key = keys?["youtubeApiKey"] as! String
    }
    
    // we assume we have a working internet connection
    // do a search, get results from url, parse and set dictionary
    // limited to ~500,000 per day!
    func getSearchResults(searchstring: String = "pratersauna", callback: (NSDictionary) -> ()) {
        //we only get video results
        //todo escape searchstring
        //var escapedString = searchstring.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        //todo... send referer...
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
            
            self.loaded=true
            callback(self.jsonDict)
        }
        task.resume()
    }
    
    func getIdStringForIndex(index: Int) -> String{
        var id = jsonDict["items"]?[index]!["id"] as! NSDictionary
        var idString = id["videoId"] as? String
        
        return idString!
    }
    
    func getTitleStringForIndex(index: Int) ->
        String {
        var title = jsonDict["items"]?[index]!["snippet"]! as! NSDictionary
        var titleString = title["title"] as? String
        
        return titleString!
    }
    
    func getRelatedVideo(videoId: String){
        
    }
    
}