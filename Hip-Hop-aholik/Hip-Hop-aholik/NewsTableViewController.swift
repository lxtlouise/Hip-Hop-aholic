//
//  NewsTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/9.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //Basic components of api's url
    private var id = "10005"
    private var fields = "title,teaser,storyDate,byline,image"
    private var startNumber = 1
    private var currentStartNumber = 1
    
    private var dateType = "story"
    private var output = "JSON"
    private var numberOfResults = 5
    private var apiKey = "MDI1ODYyMTQzMDE0NzExMzk0NjdiNzUxYg000"
    
    private var newsDataSource = [NewsListItem]()
    
    @IBOutlet weak var newsListTableView: UITableView!{
        didSet{
            self.newsListTableView?.delegate = self
            self.newsListTableView?.dataSource = self
        }
    }
    
    
    @IBOutlet weak var indicatorBackgroundView: UIView!{
        didSet{
            indicatorBackgroundView.layer.masksToBounds = true
            indicatorBackgroundView.layer.cornerRadius = 10
        }
    }
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    @IBOutlet weak var alertInformation: UILabel!{
        didSet{
            self.alertInformation.layer.masksToBounds = true
            self.alertInformation.layer.cornerRadius = 10
        }
    }
    private var header = MJRefreshNormalHeader()

    
    private var footer = MJRefreshAutoNormalFooter()
    
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSThread.sleepForTimeInterval(2.0)

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        UITabBar.appearance().backgroundColor = UIColor.blackColor()
        self.changeNavigationBarTextColor(forNavController: nav!)
        
        self.setHeaderRefreshControl()
        self.setFooterRefreshControl()
        
        self.spinner.startAnimating()
        
        self.header.beginRefreshing()
        
        self.setTableViewRowHeight()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setHeaderRefreshControl(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NewsTableViewController.refreshNewsList))
        self.newsListTableView.mj_header = header
        header.setTitle("Pull down for more :)", forState: MJRefreshState.Idle)
        header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    private func setFooterRefreshControl(){
        self.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NewsTableViewController.getMoreNewsData))
        self.newsListTableView.mj_footer = footer
        footer.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        footer.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    
    private func setTableViewRowHeight(){
        self.newsListTableView.estimatedRowHeight = newsListTableView.rowHeight
        self.newsListTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    
    
    
    func getNewsDataSource(){
        let NPR_URL = "http://api.npr.org/query?id=\(id)&fields=\(fields)&startNum=\(startNumber)&dateType=\(dateType)&output=\(output)&numResults=\(numberOfResults)&apiKey=\(apiKey)"
        
        let url = NSURL(string: NPR_URL)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let NewsDataSource = json["list"]!["story"] as! NSArray
                    
                    let currentNewsData = self.loadCurrentNewsData(withNewsDataSource: NewsDataSource)
                    self.newsDataSource = currentNewsData
                    dispatch_async(dispatch_get_main_queue(), {self.newsListTableView.reloadData()})
                }catch{
                    print(error)
                }
            }else{
                print(error!.description)
                
                print(HTTPStatusCode)
                self.alertInformation.hidden = false
                self.indicatorBackgroundView.hidden = true
                self.header.endRefreshing()
            }
        }
        
        
    }
    
    func getMoreNewsData(){
        
        footer.beginRefreshing()
        
        //update the api's url
        self.currentStartNumber += self.numberOfResults
        let current_API_URL = "http://api.npr.org/query?id=\(id)&fields=\(fields)&startNum=\(currentStartNumber)&dateType=\(dateType)&output=\(output)&numResults=\(numberOfResults)&apiKey=\(apiKey)"
        
        let url = NSURL(string: current_API_URL)
        
        performGetRequest(url) { (data, HTTPStatusCode, error) in
            if HTTPStatusCode == 200 && error == nil{
                do{let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let NewsDataSource = json["list"]!["story"] as! NSArray
                    let currentNewsData = self.loadCurrentNewsData(withNewsDataSource: NewsDataSource)
                    self.newsDataSource.appendContentsOf(currentNewsData)
                    dispatch_async(dispatch_get_main_queue(), {self.newsListTableView.reloadData()})
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
        }
        
        
    }
    
    private func loadCurrentNewsData(withNewsDataSource NewsDataSource: NSArray) -> [NewsListItem]{
        var currentNewsData = [NewsListItem]()
        
        for currentNews in NewsDataSource{
            let newsitem = NewsListItem()
            newsitem.title = currentNews["title"]!!["$text"] as! String
            
            
            newsitem.teaser = currentNews["teaser"]!!["$text"] as! String
            
            let linkList = currentNews["link"] as! NSArray
            
            for link in linkList{
                if link["type"] as! NSString == "html"{
                    newsitem.link = link["$text"] as! String
                }
            }
            
            let imageList = currentNews["image"] as! NSArray
            
            for image in imageList{
                let imageCrop = image["crop"] as! NSArray
                for imageCropItem in imageCrop{
                    if imageCropItem["type"] as! NSString == "wide"{
                        newsitem.imageURL = image["crop"]!![2]["src"] as! String
                    }
                }
            }
            
            newsitem.date = currentNews["storyDate"]!!["$text"] as! String
            
            currentNewsData.append(newsitem)
            
        }
        return currentNewsData
    }
    
    
    func refreshNewsList(){
        self.alertInformation.hidden = true
        self.newsDataSource.removeAll()
        self.getNewsDataSource()
    }

        
    
    //MARK: - Table view data source
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsDataSource.count
    }
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.NewsListIdentifier, forIndexPath: indexPath) as! NewsListTableViewCell
        let item = newsDataSource[indexPath.row]
        
        cell.newsTitle.text = item.title as String
        cell.newsTeaser.text = item.teaser as String
        cell.newsLink = item.link as String
        cell.newsStoryDate.text = "Date: \(item.date as String)"
        
        if let url = NSURL(string: item.imageURL as String){
            cell.newsImage.kf_showIndicatorWhenLoading = true
            cell.newsImage.kf_indicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            cell.newsImage.kf_indicator?.color = UIColor.grayColor()
        
            dispatch_async(dispatch_get_main_queue()) {cell.newsImage.kf_setImageWithURL(url)}
        }
        self.header.endRefreshing()
        self.footer.endRefreshing()
        self.spinner.stopAnimating()
        self.indicatorBackgroundView.hidden = true
        
        return cell
    }
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowNewsContentIdentifier{
            if let nvc = segue.destinationViewController.contentViewController as? NewsContentViewController{
                let newsLink = (sender as? NewsListTableViewCell)?.newsLink
                nvc.news_URL = newsLink!
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
