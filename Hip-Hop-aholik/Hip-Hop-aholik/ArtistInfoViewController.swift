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
    @IBOutlet weak var artistInfoIntroduction: UITextView!{
        didSet{
            self.artistInfoIntroduction.alpha = 1
        }
    }
    @IBOutlet weak var playlistTableView: UITableView!{
        didSet{
            self.playlistTableView?.delegate = self
            self.playlistTableView?.dataSource = self
            self.playlistTableView.alpha = 0
        }
    }
    
    
    @IBAction func youtubeLogo(sender: AnyObject) {
        if let url = channelUrl{
            UIApplication.sharedApplication().openURL(url)
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    @IBOutlet weak var alertInformation: UILabel!{
        didSet{
            self.alertInformation.layer.masksToBounds = true
            self.alertInformation.layer.cornerRadius = 10
        }
    }
    @IBAction func SegmentControl(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            self.playlistTableView.alpha = 0
            self.spinner.alpha = 0
            self.artistInfoIntroduction.alpha = 1
        }else{
            self.artistInfoIntroduction.alpha = 0
            self.playlistTableView.alpha = 1
            self.spinner.alpha = 1
        }
    }
    
    
    var imageUrl: NSURL!
    var name: String!
    var wikiTitle: String!
    var genres: String!
    var channelUrl: NSURL!
    
    private var apiKey = "AIzaSyB3eiYLIMFUhB1_OmUH4mktmPetpAog-K0"
    
    
    private var playlist = ChannelData()
    
    
    var playlistId = String(){
        didSet{
            self.getPlaylistDetails()
        }
    }
    
    
    private var nextPageToken:String! = ""
    
    private var videosArray = [VideoItem]()
    
    private var footer = MJRefreshAutoNormalFooter()
    
    private var header = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)
        
        self.setArtistInformation()
        
        self.spinner.alpha = 0
        self.spinner.startAnimating()

        self.getIntroduction()
        self.setFooterRefreshControl()
        self.setHeaderRefreshControl()
        self.header.beginRefreshing()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setArtistInformation(){
        self.artistInfoImage.kf_showIndicatorWhenLoading = true
        self.artistInfoImage.kf_indicator?.color = UIColor.cyanColor()
        dispatch_async(dispatch_get_main_queue()) {self.artistInfoImage.kf_setImageWithURL(self.imageUrl)}
        self.artistInfoName.text = name
        self.artistInfoGenres.text = genres
    }
    
    
    func setFooterRefreshControl(){
        self.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ArtistInfoViewController.getMorePlaylistDetails))
        self.playlistTableView.mj_footer = self.footer
        self.footer.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        self.footer.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
        self.footer.setTitle("Nuttin' more", forState: MJRefreshState.NoMoreData)
        self.footer.backgroundColor = UIColor.blackColor()
        self.footer.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        self.footer.stateLabel.textColor = UIColor.cyanColor()
    }
    
    func setHeaderRefreshControl(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ArtistInfoViewController.refreshArtistInformation))
        self.playlistTableView.mj_header = self.header
        self.header.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        self.header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        self.header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
        self.header.backgroundColor = UIColor.blackColor()
        self.header.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        self.header.tintColor = UIColor.cyanColor()
        self.header.stateLabel.textColor = UIColor.cyanColor()
    }
    
    
    
    
    func getPlaylistDetails(){
        
        let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.playlistId)&key=\(apiKey)&maxResults=50"
        let url = NSURL(string: playlistURL)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let playlistDataSource = json["items"] as! NSArray
                    let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                    self.videosArray = playlistDataArray
                    if json["nextPageToken"] != nil{
                        self.nextPageToken = json["nextPageToken"] as! String
                    }
                    dispatch_async(dispatch_get_main_queue()) {self.playlistTableView.reloadData()}
                }catch{
                    print(error)
                }
            }else{
                print(error?.description)
                print(HTTPStatusCode)
                self.alertInformation.hidden = false
                self.spinner.hidden = true
                self.header.endRefreshing()
            }
        }
        
    }
    
    func getMorePlaylistDetails(){
        if self.nextPageToken != ""{
            self.footer.beginRefreshing()
            let playlistURL = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(self.playlistId)&key=\(apiKey)&maxResults=50&pageToken=\(self.nextPageToken)"
            let url = NSURL(string: playlistURL)
            
            performGetRequest(url) { (data, HTTPStatusCode, error) in
                if HTTPStatusCode == 200 && error == nil{
                    do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let playlistDataSource = json["items"] as! NSArray
                let playlistDataArray = self.loadPlaylistDataArray(withPlaylistDataSource: playlistDataSource)
                self.videosArray.appendContentsOf(playlistDataArray)
                if let pageToken = json["nextPageToken"] as! String?{
                    self.nextPageToken = pageToken
                }else{
                    self.nextPageToken = ""
                }
                
                dispatch_async(dispatch_get_main_queue()) {self.playlistTableView.reloadData()}
                    }catch{
                        print(error)
                    }
                }else{
                    print(error?.description)
                    print(HTTPStatusCode)
                    self.alertInformation.hidden = false
                    self.spinner.hidden = true
                    self.header.endRefreshing()
                }
            }
        }else{
            self.footer.endRefreshingWithNoMoreData()
        }
        
    }
    
    func loadPlaylistDataArray(withPlaylistDataSource playlistDataSource: NSArray) -> [VideoItem]{
        
        var playlistDataArray = [VideoItem]()
        
        for video in playlistDataSource{
            let videoitem = VideoItem()
            videoitem.videoTitle = video["snippet"]!!["title"] as! String
            videoitem.videoDescription = video["snippet"]!!["description"] as! String
            videoitem.videoThumbnails = video["snippet"]!!["thumbnails"] as! NSDictionary
            videoitem.videoId = video["snippet"]!!["resourceId"]!!["videoId"] as! String
            playlistDataArray.append(videoitem)
        }
        return playlistDataArray
    }
    
    func getIntroduction(){
        let Wiki_URL = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=\(self.wikiTitle)"
        let url = NSURL(string: Wiki_URL)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                
                let pageIdDictionay = json["query"]!["pages"] as! NSDictionary
                let pageIdArray = pageIdDictionay.allKeys
                let pageId = pageIdArray[0] as! String
                self.artistInfoIntroduction.text = "\(json["query"]!["pages"]!![pageId]!!["extract"] as! String)\n\n\nClick the link below to see the original page. :)\nhttps://en.wikipedia.org/wiki/\(self.wikiTitle)\nClick the link below to see the revision history. :)\nhttps://en.wikipedia.org/w/index.php?title=\(self.wikiTitle)&action=history"
                }catch{
                    print(error)
                }
                
            }else{
                print(error?.description)
                print(HTTPStatusCode)
                self.alertInformation.hidden = false
                self.spinner.hidden = true
                self.header.endRefreshing()
            }
        }
        
    }
    
    func refreshArtistInformation(){
        self.alertInformation.hidden = true
        self.videosArray.removeAll()
        self.getPlaylistDetails()
        self.getIntroduction()
    }
    
    
    //Mark: -table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.PlaylistIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
        let item = self.videosArray[indexPath.row]
        cell.videoTitle.text = item.videoTitle
        if let imageUrl = NSURL(string: item.videoThumbnails["medium"]!["url"] as! String){
            dispatch_async(dispatch_get_main_queue()) {cell.videoImage.kf_setImageWithURL(imageUrl)}
            cell.videoImage.kf_showIndicatorWhenLoading = true
            cell.videoImage.kf_indicator?.color = UIColor.cyanColor()
        }
        cell.videoId = item.videoId
        self.header.endRefreshing()
        self.footer.endRefreshing()
        self.spinner.stopAnimating()
        return cell
    }
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowPlayerViewIdentifier{
            let Playervc = segue.destinationViewController.contentViewController as! MusicPlayerViewController
            let videoId = ((sender as? PlaylistTableViewCell)?.videoId)!
            Playervc.videoId = videoId
        }
    }
    
    
}
