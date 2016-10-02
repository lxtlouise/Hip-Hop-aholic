//
//  ArtistsTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/9.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit
import Kingfisher

class ArtistsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var artistsTableView: UITableView!{
        didSet{
            self.artistsTableView.delegate = self
            self.artistsTableView.dataSource = self
        }
    }
    
    @IBAction private func youtubeLogo(sender: AnyObject) {
        let url = NSURL(string: "https://www.youtube.com/")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    @IBOutlet weak var indicatorBackgroundView: UIView!{
        didSet{
            self.indicatorBackgroundView.layer.masksToBounds = true
            self.indicatorBackgroundView.layer.cornerRadius = 10
            
        }
    }
    
    
    @IBOutlet weak var alertInformation: UILabel!{
        didSet{
            self.alertInformation.layer.masksToBounds = true
            self.alertInformation.layer.cornerRadius = 10
        }
    }
    private var indexes=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","V","W","Y","#"]
    
    private var channelDataArray = [[ChannelData]]()
    
    private let apiKey = "AIzaSyB3eiYLIMFUhB1_OmUH4mktmPetpAog-K0"
    private var Youtube_Channel_URL: String!
    
    private var header = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)
        
        self.setTableViewSectionIndexStyle()
        self.setHeaderRefreshControl()
        
        self.spinner.startAnimating()
        
        self.header.beginRefreshing()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setHeaderRefreshControl(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ArtistsTableViewController.refreshChannelDetails))
        self.artistsTableView.mj_header = header
        header.setTitle("Pull down for more :)", forState: MJRefreshState.Idle)
        header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    private func setTableViewSectionIndexStyle(){
        self.artistsTableView.sectionIndexBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        self.artistsTableView.sectionIndexColor = UIColor.cyanColor()
    }
    
    
    private func getChannelDetails(){
        for i in 0..<artistsTableData.count{
            self.channelDataArray.append([ChannelData]())
            for j in 0..<artistsTableData[i].count{
                let name = artistsTableData[i][j]
                if let channelName = artistInfoDictionary[name]?.artistChannelName{
                    self.Youtube_Channel_URL = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(channelName)&key=\(apiKey)"
                }else if let channelID = artistInfoDictionary[name]?.artistChannelID{
                    self.Youtube_Channel_URL = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(channelID)&key=\(apiKey)"
                }
                
                let url = NSURL(string: Youtube_Channel_URL)
                
                performGetRequest(url) { (data, HTTPStatusCode, error) in
                    if HTTPStatusCode == 200 && error == nil{
                        do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
                            let channelDataSource = (json["items"] as! NSArray)[0] as! NSDictionary
                            let channelData = ChannelData()
                            
                            channelData.channelName = channelDataSource["snippet"]!["localized"]!!["title"] as! String
                            channelData.thumbnails = channelDataSource["snippet"]!["thumbnails"] as! NSDictionary
                            channelData.playlistId = channelDataSource["contentDetails"]!["relatedPlaylists"]!!["uploads"] as! String
                            channelData.artistName = name
                            if let channelName = artistInfoDictionary[name]?.artistChannelName{
                                channelData.channelUrl = NSURL(string:"https://www.youtube.com/user/\(channelName)")
                            }else if let channelID = artistInfoDictionary[name]?.artistChannelID{
                                channelData.channelUrl = NSURL(string:"https://www.youtube.com/channel/\(channelID)")
                            }
                            
                            self.channelDataArray[i].append(channelData)
                            self.channelDataArray[i].sortInPlace({$0.artistName.lowercaseString < $1.artistName.lowercaseString})
                            dispatch_async(dispatch_get_main_queue()) {self.artistsTableView.reloadData()}
                        }catch {
                            print(error)
                            
                        }
                    }else{
                        print(error?.description)
                        
                        print(HTTPStatusCode)
                        self.alertInformation.hidden = false
                        self.indicatorBackgroundView.hidden = true
                        self.header.endRefreshing()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func refreshChannelDetails(){
        self.alertInformation.hidden = true
        self.channelDataArray.removeAll()
        self.getChannelDetails()
        
    }
    
    
    
    
    // MARK: - Table view data source
    
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.indexes
    }
    
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var  tableIndex: Int = 0
        
        for character in indexes{
            if character == title{
                return tableIndex
            }
            tableIndex += 1
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.channelDataArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelDataArray[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.ArtistsIdentifier, forIndexPath: indexPath) as! ArtistsTableViewCell
        
        let channelDataItem = self.channelDataArray[indexPath.section][indexPath.row]
        
        if let imageUrl = NSURL(string: channelDataItem.thumbnails["medium"]!["url"] as! String){
            cell.artistImage.kf_setImageWithURL(imageUrl)
            dispatch_async(dispatch_get_main_queue()) {cell.artistImage.kf_setImageWithURL(imageUrl)}
            cell.imageUrl = imageUrl
        }
        cell.artistName.text = channelDataItem.artistName
        cell.playlistId = channelDataItem.playlistId
        cell.channelUrl = channelDataItem.channelUrl
        
        cell.artistImage.layer.cornerRadius = cell.artistImage.frame.size.width/2
        cell.artistImage.clipsToBounds = true
        
        self.header.endRefreshing()
        self.spinner.stopAnimating()
        self.indicatorBackgroundView.hidden = true
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.blackColor()
        let sectionHeader = view as! UITableViewHeaderFooterView
        sectionHeader.textLabel?.textColor = UIColor.cyanColor()
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowArtistInfoIdentifier{
            if let artistInfovc = segue.destinationViewController.contentViewController as? ArtistInfoViewController{
                let name = (sender as? ArtistsTableViewCell)!.artistName.text
                let imageUrl = (sender as? ArtistsTableViewCell)!.imageUrl
                let channelUrl = (sender as? ArtistsTableViewCell)!.channelUrl
                artistInfovc.navigationItem.title = name!
                artistInfovc.imageUrl = imageUrl
                artistInfovc.name = name!
                artistInfovc.channelUrl = channelUrl
                var genres = artistInfoDictionary[name!]!.artistGenres
                genres = "Genres: "
                for genre in genresTableData{
                    
                    if artistsOfGenreDictionary[genre]!.contains(name!){
                        
                        genres.appendContentsOf("\(genre)/ ")
                    }
                }
                let finalGenresResult = String(genres.characters.dropLast(2))
                artistInfovc.genres = finalGenresResult
                artistInfovc.wikiTitle = artistInfoDictionary[name!]!.artistWikiTitle
                artistInfovc.playlistId = "\((sender as? ArtistsTableViewCell)!.playlistId)"
                
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    
    
}

