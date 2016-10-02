//
//  WikiViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/31.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit
import Kingfisher

class WikiTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var wikiTableView: UITableView!{
        didSet{
            self.wikiTableView?.delegate = self
            self.wikiTableView?.dataSource = self
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var indicatorBackgroundView: UIView!
    
    @IBOutlet weak var alertInformation: UILabel!
    private var videosArray = [VideoItem]()
    
    private var filteredVideosArray = [VideoItem]()
    
    private var sources = ["www.genius.com","rappingmanual.com"]
    
    private var nextPageToken_Genius: String!
    
    private var nextPageToken_RappingManual: String!
    
    private var rap_genius_playlistId = "UUyFZMEnm1il5Wv3a6tPscbA"
    
    private var rapping_manual_playlistId = "UUdWpFHyqvBGuBWyeiJGaD7Q"
    
    private var apiKey = "AIzaSyB3eiYLIMFUhB1_OmUH4mktmPetpAog-K0"
    
    private var footer = MJRefreshAutoNormalFooter()
    private var header = MJRefreshNormalHeader()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)
        
        self.searchBar.delegate = self
        self.indicatorBackgroundView.layer.masksToBounds = true
        self.indicatorBackgroundView.layer.cornerRadius = 10
        self.alertInformation.layer.masksToBounds = true
        self.alertInformation.layer.cornerRadius = 10
        
        self.spinner.startAnimating()
        self.setHeaderRefreshControl()
        self.setFooterRefreshControl()
        self.header.beginRefreshing()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setHeaderRefreshControl(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(WikiTableViewController.refreshPlaylistDetails))
        self.wikiTableView.mj_header = self.header
        header.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    private func setFooterRefreshControl(){
        self.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(WikiTableViewController.getMorePlaylistDetails))
        self.wikiTableView.mj_footer = self.footer
        footer.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        footer.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
        footer.setTitle("Nuttin' more", forState: MJRefreshState.NoMoreData)
    }
    
    
    private func getPlaylistDetails(){
        let rap_genius_playlist_url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rap_genius_playlistId)&key=\(self.apiKey)&maxResults=50"
        
        let genius_url = NSURL(string: rap_genius_playlist_url)
        
        let rapping_manual_playlist_url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rapping_manual_playlistId)&key=\(self.apiKey)&maxResults=50"
        
        
        let rapping_manual_url = NSURL(string: rapping_manual_playlist_url)
        
        performGetRequest(genius_url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let playlistDataSource = json["items"] as! NSArray
                    let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                    self.videosArray.appendContentsOf(playlistDataArray)
                    if json["nextPageToken"] != nil{
                        self.nextPageToken_Genius = json["nextPageToken"] as! String
                    }
                }catch{
                    print(error)
                }
            }else{
                print(error?.description)
                print(HTTPStatusCode)
                self.alertInformation.hidden = false
                self.indicatorBackgroundView.hidden = true
                self.header.endRefreshing()
                
            }
            self.videosArray.sortInPlace({$0.publishedDate > $1.publishedDate})
            self.filteredVideosArray = self.videosArray
            dispatch_async(dispatch_get_main_queue()) {self.wikiTableView.reloadData()}
            
        }
        
        
        performGetRequest(rapping_manual_url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let playlistDataSource = json["items"] as! NSArray
                    let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                    self.videosArray.appendContentsOf(playlistDataArray)
                    if json["nextPageToken"] != nil{
                        self.nextPageToken_RappingManual = json["nextPageToken"] as! String
                    }
                }catch{
                    print(error)
                }
            }else{
                print(error?.description)
                print(HTTPStatusCode)
                self.alertInformation.hidden = false
                self.indicatorBackgroundView.hidden = true
                self.header.endRefreshing()
            }
            self.videosArray.sortInPlace({$0.publishedDate > $1.publishedDate})
            self.filteredVideosArray = self.videosArray
            dispatch_async(dispatch_get_main_queue()) {self.wikiTableView.reloadData()}
            
        }
    }
    
    func getMorePlaylistDetails(){
        
        if self.nextPageToken_Genius != "" || self.nextPageToken_RappingManual != ""{
            self.footer.beginRefreshing()
            var temporaryVideosArray = [VideoItem]()
            if self.nextPageToken_Genius != ""{
                let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rap_genius_playlistId)&key=\(self.apiKey)&maxResults=50&pageToken=\(self.nextPageToken_Genius)"
                
                let url = NSURL(string: playlistURL)
                
                performGetRequest(url) { (data, HTTPStatusCode, error) in
                    if HTTPStatusCode == 200 && error == nil{
                        do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
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
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {self.wikiTableView.reloadData()}
                        }catch{
                            print(error)
                        }
                    }else{
                        print(error)
                        print(HTTPStatusCode)
                        self.alertInformation.hidden = false
                        self.indicatorBackgroundView.hidden = true
                        self.header.endRefreshing()
                        
                    }
                }
            }
            if self.nextPageToken_RappingManual != ""{
                let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.rapping_manual_playlistId)&key=\(self.apiKey)&maxResults=50&pageToken=\(self.nextPageToken_RappingManual)"
                
                let url = NSURL(string: playlistURL)
                
                performGetRequest(url) { (data, HTTPStatusCode, error) in
                    if HTTPStatusCode == 200 && error == nil{
                        do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
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
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {self.wikiTableView.reloadData()}
                        }catch{
                            print(error)
                        }
                    }else{
                        print(error)
                        print(HTTPStatusCode)
                        self.alertInformation.hidden = false
                        self.indicatorBackgroundView.hidden = true
                        self.header.endRefreshing()
                    }
                }
            }
            
        }else{
            self.footer.endRefreshingWithNoMoreData()
        }
        
    }
    
    
    
    private func loadPlaylistDataArray(withPlaylistDataSource playlistDataSource: NSArray) -> [VideoItem]{
        
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
    
    func refreshPlaylistDetails(){
        self.alertInformation.hidden = true
        self.videosArray.removeAll()
        self.getPlaylistDetails()
    }
    
    // MARK: - Table view data source
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredVideosArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.WikiPlaylistIdentifier, forIndexPath: indexPath) as! WikiTableViewCell
        let item = self.filteredVideosArray[indexPath.row]
        cell.videoTitle.text = item.videoTitle
        if let imageUrl = NSURL(string: item.videoThumbnails["medium"]!["url"] as! String){
            dispatch_async(dispatch_get_main_queue()) {cell.videoImage.kf_setImageWithURL(imageUrl)}
            cell.videoImage.kf_showIndicatorWhenLoading = true
        }
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
        self.wikiTableView.reloadData()
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
