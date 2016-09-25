//
//  WikiViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/31.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit
import Kingfisher

class WikiViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sourcesTableView: UITableView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var indicatorBackgroundView: UIView!
    var videosArray = [VideoItem]()
    
    var filteredVideosArray = [VideoItem]()
    
    var sources = ["www.genius.com","rappingmanual.com"]
    
    var nextPageToken_Genius: String! = ""
    
    var nextPageToken_RappingManual: String! = ""
    
    var rap_genius_playlistId = "UUyFZMEnm1il5Wv3a6tPscbA"
    
    var rapping_manual_playlistId = "UUdWpFHyqvBGuBWyeiJGaD7Q"
    
    var apiKey = "AIzaSyB3eiYLIMFUhB1_OmUH4mktmPetpAog-K0"
    
    var footer = MJRefreshAutoNormalFooter()
    var header = MJRefreshNormalHeader()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)

        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        searchBar.delegate = self
        self.indicatorBackgroundView.layer.masksToBounds = true
        self.indicatorBackgroundView.layer.cornerRadius = 10
        
        self.spinner.startAnimating()
        self.setHeader()
        self.setFooter()
        self.header.beginRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setHeader(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(WikiViewController.resetPlaylistDetails))
        self.tableView.mj_header = self.header
        header.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    func setFooter(){
        self.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(WikiViewController.getMorePlaylistDetails))
        self.tableView.mj_footer = self.footer
        footer.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        footer.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
        footer.setTitle("Nuttin' more", forState: MJRefreshState.NoMoreData)
    }
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    func getPlaylistDetails(){
        let rap_genius_playlist_url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rap_genius_playlistId)&key=\(self.apiKey)&maxResults=50"

        let genius_url = NSURL(string: rap_genius_playlist_url)
        
        let rapping_manual_playlist_url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rapping_manual_playlistId)&key=\(self.apiKey)&maxResults=50"

        
        let rapping_manual_url = NSURL(string: rapping_manual_playlist_url)
        
        performGetRequest(genius_url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let playlistDataSource = json["items"] as! NSArray
                let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                self.videosArray.appendContentsOf(playlistDataArray)
                if json["nextPageToken"] != nil{
                    self.nextPageToken_Genius = json["nextPageToken"] as! String
                    
                }
            }else{
                print(error)
                print(HTTPStatusCode)
            }
            self.videosArray.sortInPlace({$0.publishedDate > $1.publishedDate})
            self.filteredVideosArray = self.videosArray
            dispatch_async(dispatch_get_main_queue()) {self.tableView.reloadData()}
            
        }
        
        performGetRequest(rapping_manual_url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let playlistDataSource = json["items"] as! NSArray
                let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                self.videosArray.appendContentsOf(playlistDataArray)
                if json["nextPageToken"] != nil{
                    self.nextPageToken_RappingManual = json["nextPageToken"] as! String
                    
                }
            }
            self.videosArray.sortInPlace({$0.publishedDate > $1.publishedDate})
            self.filteredVideosArray = self.videosArray
            dispatch_async(dispatch_get_main_queue()) {self.tableView.reloadData()}
            
        }
    }
    
    func getMorePlaylistDetails(){
        
        if self.nextPageToken_Genius != "" || self.nextPageToken_RappingManual != ""{
            self.footer.beginRefreshing()
            var temporaryVideosArray = [VideoItem]()
            if self.nextPageToken_Genius != ""{
                let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rap_genius_playlistId)&key=\(self.apiKey)&maxResults=50&pageToken=\(self.nextPageToken_Genius)"
                print(playlistURL)
                let url = NSURL(string: playlistURL)
                
                performGetRequest(url) { (data, HTTPStatusCode, error) in
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let playlistDataSource = json["items"] as! NSArray
                    let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                    temporaryVideosArray.appendContentsOf(playlistDataArray)
                    if let pageToken = json["nextPageToken"] as! String?{
                        self.nextPageToken_Genius = pageToken
                    }else{
                        self.nextPageToken_Genius = ""
                    }
                    temporaryVideosArray.sortInPlace({$0.publishedDate > $1.publishedDate})
                    self.videosArray.appendContentsOf(temporaryVideosArray)
                    self.filteredVideosArray.appendContentsOf(temporaryVideosArray)
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {self.tableView.reloadData()}
                }
            }
            if self.nextPageToken_RappingManual != ""{
                let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rapping_manual_playlistId)&key=\(self.apiKey)&maxResults=50&pageToken=\(self.nextPageToken_RappingManual)"
                print(playlistURL)
                let url = NSURL(string: playlistURL)
                
                performGetRequest(url) { (data, HTTPStatusCode, error) in
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let playlistDataSource = json["items"] as! NSArray
                    let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                    temporaryVideosArray.appendContentsOf(playlistDataArray)
                    if let pageToken = json["nextPageToken"] as! String?{
                        self.nextPageToken_RappingManual = pageToken
                    }else{
                        self.nextPageToken_RappingManual = ""
                    }
                    temporaryVideosArray.sortInPlace({$0.publishedDate > $1.publishedDate})
                    self.videosArray.appendContentsOf(temporaryVideosArray)
                    self.filteredVideosArray.appendContentsOf(temporaryVideosArray)
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {self.tableView.reloadData()}
                }
            }
            
        }else{
            self.footer.endRefreshingWithNoMoreData()
        }
        
    }
    
    func resetPlaylistDetails(){
        self.videosArray.removeAll()
        self.tableView.reloadData()
        self.getPlaylistDetails()
    }
    
    func loadPlaylistDataArray(withPlaylistDataSource playlistDataSource: NSArray) -> [VideoItem]{
        
        var playlistDataArray = [VideoItem]()
        
        for video in playlistDataSource{
            let videoitem = VideoItem()
            videoitem.videoTitle = video["snippet"]!!["title"] as! String
            videoitem.videoDescription = video["snippet"]!!["description"] as! String
            videoitem.videoThumbnails = video["snippet"]!!["thumbnails"] as! NSDictionary
            videoitem.videoId = video["snippet"]!!["resourceId"]!!["videoId"] as! String
            videoitem.publishedDate = video["snippet"]!!["publishedAt"] as! String
            videoitem.channelTag = "#\(video["snippet"]!!["channelTitle"] as! String)"
            playlistDataArray.append(videoitem)
        }
        return playlistDataArray
    }
    
    
    // MARK: - Table view data source
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredVideosArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.WikiPlaylistIdentifier, forIndexPath: indexPath) as! WikiTableViewCell
        let item = self.filteredVideosArray[indexPath.row]
        cell.videoTitle.text = item.videoTitle
        let imageUrl = NSURL(string: item.videoThumbnails["medium"]!["url"] as! String)
        cell.videoImage.kf_setImageWithURL(imageUrl)
        cell.videoId = item.videoId
        cell.channelTag = item.channelTag
        self.indicatorBackgroundView.hidden = true
        self.spinner.stopAnimating()
        self.header.endRefreshing()
        self.footer.endRefreshing()
        
        return cell
    }
    
    //MARK: - Search bar delegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            filteredVideosArray = self.videosArray
        }else{
            var resultsArray = [VideoItem]()
            for video in videosArray{
                if searchText.hasPrefix("#"){
                    if video.channelTag.lowercaseString.rangeOfString(searchText.lowercaseString) != nil{
                        resultsArray.append(video)
                    }
                }else if video.videoTitle.lowercaseString.rangeOfString(searchText.lowercaseString) != nil{
                    resultsArray.append(video)
                }
            }
            filteredVideosArray = resultsArray
        }
        self.tableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowWikiIdentifier{
            let wikivc = segue.destinationViewController.contentViewController as? WikiPlayerViewController
            let Id = (sender as? WikiTableViewCell)?.videoId
            wikivc!.videoId = Id!
            
        }
    }
    
    /*override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }*/

}
