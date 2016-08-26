//
//  ArtistInfoViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/11.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var artistInfoImage: UIImageView!
    @IBOutlet weak var artistInfoName: UILabel!
    @IBOutlet weak var artistInfoGenres: UILabel!
    @IBOutlet weak var artistInfoIntroduction: UITextView!
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBAction func SegmentControl(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            self.playlistTableView.alpha = 0
            self.artistInfoIntroduction.alpha = 1
        }else{
            self.artistInfoIntroduction.alpha = 0
            self.playlistTableView.alpha = 1
        }
    }
    
    
    var image: UIImage = UIImage()
    var name: String = String()
    var wikiTitle: String = String()
    var genres: String = String()
    var intro: String = String()
    
    var apiKey = "AIzaSyB3eiYLIMFUhB1_OmUH4mktmPetpAog-K0"
    
    var channelName = ""
    
    var playlist = ChannelData()
    
    var Youtube_Channel_URL = ""
    
    var playlistID = ""{
        didSet{
            self.getPlaylistDetails()
        }
    }
    
    var playlistURL = ""
    
    var nextPageToken:String! = ""
    
    var videosArray = NSMutableArray()

    var footerRefreshControl = MJRefreshAutoNormalFooter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setArtistInformation()
        playlistTableView?.delegate = self
        playlistTableView?.dataSource = self
        self.playlistTableView.registerClass(PlaylistTableViewCell.self, forCellReuseIdentifier:StoryboardIdentifiers.EmbedPlaylistIdentifier)
        self.playlistTableView.alpha = 0
        self.artistInfoIntroduction.alpha = 1
        self.setFooterRefresh()
        self.getIntroduction()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        self.setApiUrl()
        self.getChannelDetails()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setArtistInformation(){
        self.artistInfoImage.image = image
        self.artistInfoName.text = name
        self.artistInfoGenres.text = genres
        //self.artistInfoIntroduction.text = intro
    }
    
    func setApiUrl(){
        self.Youtube_Channel_URL = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=UCedvOgsKFzcK3hA5taf3KoQ&key=\(apiKey)"
        print(Youtube_Channel_URL)
    }
    
    func setFooterRefresh(){
        self.footerRefreshControl = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ArtistInfoViewController.getMorePlaylistDetails))
        self.playlistTableView.mj_footer = self.footerRefreshControl
        self.footerRefreshControl.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        self.footerRefreshControl.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
        self.footerRefreshControl.setTitle("Nuttin' more", forState: MJRefreshState.NoMoreData)
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

    
    func getChannelDetails(){
        
        let urlString = Youtube_Channel_URL
        let url = NSURL(string: urlString)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let channelDataSource = json["items"]![0] as! NSDictionary
                let channelData = ChannelData()
                channelData.thumbnails = channelDataSource["snippet"]!["thumbnails"] as! NSDictionary
                channelData.playlistId = channelDataSource["contentDetails"]!["relatedPlaylists"]!!["uploads"] as! String
                self.playlist = channelData
                self.playlistID = self.playlist.playlistId
                self.nextPageToken = self.playlist.nextPageToken
                print(self.playlist.playlistId)
                }catch{
                    print(error)
                }
            }else{
                print(error)
            }
        }
        
    }
    
    func getPlaylistDetails(){
        
        let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.playlistID)&key=\(apiKey)&maxResults=50"
        print(playlistURL)
        let url = NSURL(string: playlistURL)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
            
            let playlistDataSource = json["items"] as! NSArray
            let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
            self.videosArray = playlistDataArray
            if json["nextPageToken"] != nil{
                self.nextPageToken = json["nextPageToken"] as! String
            }
                   dispatch_async(dispatch_get_main_queue()) {self.playlistTableView.reloadData()}
        }
    }
    
    func getMorePlaylistDetails(){
        if self.nextPageToken != ""{
            self.footerRefreshControl.beginRefreshing()
            let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.playlistID)&key=\(apiKey)&maxResults=50&pageToken=\(self.nextPageToken)"
            print(playlistURL)
            let url = NSURL(string: playlistURL)
            
            performGetRequest(url) { (data, HTTPStatusCode, error) in
                let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let playlistDataSource = json["items"] as! NSArray
                let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                self.videosArray.addObjectsFromArray(playlistDataArray as [AnyObject])
                if let pageToken = json["nextPageToken"] as! String?{
                    self.nextPageToken = pageToken
                }else{
                    self.nextPageToken = ""
                }

                dispatch_async(dispatch_get_main_queue()) {self.playlistTableView.reloadData()}
            self.footerRefreshControl.endRefreshing()
            }
        }else{
            self.footerRefreshControl.endRefreshingWithNoMoreData()
        }
        
    }
    
    func loadPlaylistDataArray(withPlaylistDataSource playlistDataSource: NSArray) -> NSMutableArray{
        
        let playlistDataArray = NSMutableArray()
        
        for video in playlistDataSource{
            let videoitem = VideoItem()
            videoitem.videoTitle = video["snippet"]!!["title"] as! String
            videoitem.videoDescription = video["snippet"]!!["description"] as! String
            videoitem.videoThumbnails = video["snippet"]!!["thumbnails"] as! NSDictionary
            videoitem.videoId = video["snippet"]!!["resourceId"]!!["videoId"] as! String
            playlistDataArray.addObject(videoitem)
        }
        return playlistDataArray
    }

    func getIntroduction(){
        let Wiki_URL = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=\(self.wikiTitle)"
        let url = NSURL(string: Wiki_URL)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let pageIdDictionay = json["query"]!["pages"] as! NSDictionary
                let pageIdArray = pageIdDictionay.allKeys
                let pageId = pageIdArray[0] as! String
                self.artistInfoIntroduction.text = "\(json["query"]!["pages"]!![pageId]!!["extract"] as! String)\n\n\nClick the link below to see the original page. :)\nhttps://en.wikipedia.org/wiki/\(self.wikiTitle)\nClick the link below to see the revision history. :)\nhttps://en.wikipedia.org/w/index.php?title=\(self.wikiTitle)&action=history"
                
            }
        }
        
    }
    
    //Mark: -table view data source
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosArray.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.PlaylistIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
        let item = self.videosArray[indexPath.row] as! VideoItem
        cell.videoTitle.text = item.videoTitle
        let imageUrl = NSURL(string: item.videoThumbnails["medium"]!["url"] as! String)
        cell.videoImage.kf_setImageWithURL(imageUrl)
        cell.videoId = item.videoId
        return cell
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowPlayerViewIdentifier{
            let Playervc = segue.destinationViewController.contentViewController as! PlayerViewController
            let videoId = ((sender as? PlaylistTableViewCell)?.videoId)!
            Playervc.videoID = videoId
        }
    }
    

}
