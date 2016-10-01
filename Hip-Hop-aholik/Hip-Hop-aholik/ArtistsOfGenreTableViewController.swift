//
//  ArtistsOfGenreTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/12.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistsOfGenreTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var artistsOfGenreTableView: UITableView!{
        didSet{
            self.artistsOfGenreTableView?.delegate = self
            self.artistsOfGenreTableView?.dataSource = self
        }
    }
    
    
    @IBOutlet weak var indicatorBackgroundView: UIView!{
        didSet{
            self.indicatorBackgroundView.layer.masksToBounds = true
            self.indicatorBackgroundView.layer.cornerRadius = 10
        }
    }
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var alertInformation: UILabel!{
        didSet{
            self.alertInformation.layer.masksToBounds = true
            self.alertInformation.layer.cornerRadius = 10
        }
    }
    @IBAction func youtubeLog(sender: UIButton) {
        let url = NSURL(string: "https://www.youtube.com/")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
    
    var wikiTitle = String(){
        didSet{
            self.getGenreWiki()
        }
    }
    var artistsOfGenreTableData = [String]()
    
   
    private var channelDataArray = [ChannelData]()
    
    private var genreIntroduction: String!
    
    
    private var selectedIndexPath: NSIndexPath?
    
    private let apiKey = "AIzaSyB3eiYLIMFUhB1_OmUH4mktmPetpAog-K0"
    
    private var Youtube_Channel_URL: String!
    
    private var wikiPedia_URL: String!
    
    private var header = MJRefreshNormalHeader()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)
        
        let item = UIBarButtonItem(title: "...", style: .Done, target: self, action: #selector(self.openActivityController(_:)))
        let titleTextAttributes: NSDictionary = [NSFontAttributeName: UIFont.boldSystemFontOfSize(28.0)]
        item.setTitleTextAttributes(titleTextAttributes as? [String : AnyObject], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = item
        
        self.spinner.startAnimating()
        
        self.setHeaderRefreshControl()
        self.header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setHeaderRefreshControl(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ArtistsOfGenreTableViewController.refreshWikiAndChannelDetails))
        self.artistsOfGenreTableView.mj_header = header
        header.setTitle("Pull down for more :)", forState: MJRefreshState.Idle)
        header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }

    
    
    private func getChannelDetails(){
            for i in 0..<artistsOfGenreTableData.count{
                let name = artistsOfGenreTableData[i]
                
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
                            channelData.channelName = (channelDataSource["snippet"]!["localized"]!!["title"] as? String)!
                            channelData.thumbnails = channelDataSource["snippet"]!["thumbnails"] as! NSDictionary
                            channelData.playlistId = channelDataSource["contentDetails"]!["relatedPlaylists"]!!["uploads"] as! String
                            channelData.artistName = name
                            if let channelName = artistInfoDictionary[name]?.artistChannelName{
                                channelData.channelUrl = NSURL(string:"https://www.youtube.com/user/\(channelName)")
                            }else if let channelID = artistInfoDictionary[name]?.artistChannelID{
                                channelData.channelUrl = NSURL(string:"https://www.youtube.com/channel/\(channelID)")
                            }

                            self.channelDataArray.append(channelData)
                            self.channelDataArray.sortInPlace({$0.artistName.lowercaseString < $1.artistName.lowercaseString})
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
                    dispatch_async(dispatch_get_main_queue()) {self.artistsOfGenreTableView.reloadData()}
                }
            }
        }
    
    
    
    private func getGenreWiki(){
        if self.wikiTitle == "Political_hip_hop#Conscious_hip_hop"{
            let wiki_URL = "https://en.wikipedia.org/w/api.php?action=parse&format=json&title=Political+Hip+Hop&text=Conscious+hip+hop%2C+or+socially+conscious+hip-hop%2C+is+a+subgenre+of+hip+hop+that+challenges+the+dominant+cultural%2C+political%2C+philosophical%2C+and+economic+consensus%2C+and%2For+comments+on+social+issues+and+conflicts.+Conscious+hip+hop+is+not+necessarily+overtly+political%2C+but+the+two+are+sometimes+used+interchangeably.+The+term+%22nation-conscious+rap%22+has+been+used+to+more+specifically+describe+hip+hop+music+with+strong+political+messages+and+themes.+Themes+of+conscious+hip+hop+include+afrocentricity%2C+religion%2C+aversion+to+crime+%26+violence%2C+culture%2C+the+economy%2C+or+depictions+of+the+struggles+of+ordinary+people.+Conscious+hip+hop+often+seeks+to+raise+awareness+of+social+issues%2C+leaving+the+listeners+to+form+their+own+opinions%2C+rather+than+aggressively+advocating+for+certain+ideas+and+demanding+actions.&prop=wikitext"
            
            self.wikiPedia_URL = "https://en.wikipedia.org/wiki/Political_hip_hop#Conscious_hip_hop"
            let url = NSURL(string: wiki_URL)
            performGetRequest(url) { (data, HTTPStatusCode, error) in
                if HTTPStatusCode == 200 && error == nil{
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let parseDictionay = json["parse"]!["wikitext"] as! NSDictionary
                    
                    self.genreIntroduction = "\(parseDictionay["*"]!)\n\n\nThe link below is the original page. :)\nClick the top right button to view it in Safari\nhttps://en.wikipedia.org/wiki/\(self.wikiTitle)\nThe link below is the revision history. :)\nhttps://en.wikipedia.org/w/index.php?title=\(self.wikiTitle)&action=history"
                    
                }
                dispatch_async(dispatch_get_main_queue()) {self.artistsOfGenreTableView.reloadData()}
            }
            
        }else{
            let wiki_URL = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=\(self.wikiTitle)"
            self.wikiPedia_URL = "https://en.wikipedia.org/wiki/\(self.wikiTitle)"
            let url = NSURL(string: wiki_URL)
            
            performGetRequest(url) { (data, HTTPStatusCode, error) in
                if HTTPStatusCode == 200 && error == nil{
                    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    
                    let pageIdDictionay = json["query"]!["pages"] as! NSDictionary
                    let pageIdArray = pageIdDictionay.allKeys
                    let pageId = pageIdArray[0] as! String
                    self.genreIntroduction = "\(json["query"]!["pages"]!![pageId]!!["extract"] as! String)\n\n\nThe link below is the original page. :)\nClick the top right button to view it in Safari\nhttps://en.wikipedia.org/wiki/\(self.wikiTitle)\nThe link below is the revision history. :)\nhttps://en.wikipedia.org/w/index.php?title=\(self.wikiTitle)&action=history"
                    
                }
                dispatch_async(dispatch_get_main_queue()) {self.artistsOfGenreTableView.reloadData()}
            }
        }
        
    }

    func refreshWikiAndChannelDetails(){
        self.alertInformation.hidden = true
        self.channelDataArray.removeAll()
        self.getChannelDetails()
        self.getGenreWiki()
    }


    func openActivityController(sender: UIButton){
        let acts = [WikiSafari()]
        if let url = NSURL(string: wikiPedia_URL){
            let objectsToShare = [url]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: acts)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeAssignToContact]
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }

    

    

    // MARK: - Table view data source
    
    //intialize table view
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return self.channelDataArray.count
        }
        
    }

    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.GenreIntroductionIdentifier, forIndexPath: indexPath) as! GenreWikiTableViewCell
            let intro = genreIntroduction
            cell.genreWiki.text = intro
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.ArtistsOfGenreIdentifier, forIndexPath: indexPath) as! ArtistsOfGenreTableViewCell
            let channelDataItem = self.channelDataArray[indexPath.row]
            
            cell.artistOfGenreName.text = channelDataItem.artistName
            
            if let imageUrl = NSURL(string: channelDataItem.thumbnails["medium"]!["url"] as! String){
                cell.imageUrl = imageUrl
                dispatch_async(dispatch_get_main_queue()) {cell.artistOfGenreImage.kf_setImageWithURL(imageUrl)}
                cell.artistOfGenreImage.kf_showIndicatorWhenLoading = true
            }
            
            cell.playlistId = channelDataItem.playlistId
            cell.channelUrl = channelDataItem.channelUrl
            
            cell.artistOfGenreImage.layer.cornerRadius = 20
            cell.artistOfGenreImage.clipsToBounds = true
            
            self.header.endRefreshing()
            self.spinner.stopAnimating()
            self.indicatorBackgroundView.hidden = true
            
            return cell
        }
        
    }
    
    
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Introduction"
        }else{
            return "Artists"
        }
    }
    
     func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0{
            return "Click the Intro to expand/collapse"
        }else{
            return nil
        }
    }
    
     func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.whiteColor()
        let sectionFooter = view as! UITableViewHeaderFooterView
        sectionFooter.textLabel?.textColor = UIColor.grayColor()
        sectionFooter.textLabel?.font = UIFont.systemFontOfSize(15.0)
    }
     func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.blackColor()
        let sectionHeader = view as! UITableViewHeaderFooterView
        sectionHeader.textLabel?.textColor = UIColor.cyanColor()
        
    
    }
    
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedIndexPath != nil && indexPath == selectedIndexPath{
            
            tableView.estimatedRowHeight = UITableViewAutomaticDimension
            return  tableView.estimatedRowHeight
        }else if indexPath.section == 0 {
            return 200
        }else{
            return 100
        }
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            if selectedIndexPath != nil && selectedIndexPath == indexPath{
                selectedIndexPath = nil
            }else{
                self.selectedIndexPath = indexPath
            }
            self.artistsOfGenreTableView.beginUpdates()
            self.artistsOfGenreTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.artistsOfGenreTableView.endUpdates()
        }
            
        
    }
    
     func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowArtistOfGenreInfoIdentifier{
            if let artistInfovc = segue.destinationViewController.contentViewController as? ArtistInfoViewController{
                let name = (sender as? ArtistsOfGenreTableViewCell)!.artistOfGenreName.text
                let imageUrl = (sender as? ArtistsOfGenreTableViewCell)!.imageUrl
                let channelUrl = (sender as? ArtistsOfGenreTableViewCell)!.channelUrl
                artistInfovc.navigationItem.title = name
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

                artistInfovc.playlistId = (sender as? ArtistsOfGenreTableViewCell)!.playlistId
                artistInfovc.wikiTitle = artistInfoDictionary[name!]!.artistWikiTitle
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
