//
//  NewsTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/9.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewController: UITableViewController {
    
//Basic components of api's url
    private var id = "10005"
    private var fields = "title,teaser,storyDate,byline,image"
    private var startNumber = 1
    //Due to the limit of number of news returned, we have to update the start number to get earlier news(with function loadMoreData()).
    private var currentStartNumber = 1
    
    private var dateType = "story"
    private var output = "JSON"
    private var numberOfResults = 5
    private var apiKey = "MDI1ODYyMTQzMDE0NzExMzk0NjdiNzUxYg000"
    
//Both versions of urls are set with function setApiUrl().
    //The initial url
    private var API_URL = ""
    //The updated url, corresponding to var currentStartNumber
    private var current_API_URL = ""
    
//The data source used to initialize table view, initialized with function loadDataSource() and updated with function loadMoreData()
    private var DataSource = NSMutableArray()
//The footer and header used to refresh, initialized with function setHeaderRefreshControl() and function setFooterRefreshControl(), respectively.
    private var footer = MJRefreshAutoNormalFooter()
    private var header = MJRefreshNormalHeader()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setApiUrl()
        self.setHeaderRefreshControl()
        self.header.beginRefreshing()//Begin refreshing and call function loadDataSource()
        self.setFooterRefreshControl()
        self.setTableViewRowHeight()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setApiUrl(){
        API_URL = "http://api.npr.org/query?id=\(id)&fields=\(fields)&startNum=\(startNumber)&dateType=\(dateType)&output=\(output)&numResults=\(numberOfResults)&apiKey=\(apiKey)"
        current_API_URL = API_URL
    }

    func setHeaderRefreshControl(){
        self.header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NewsTableViewController.loadDataSource))
        self.tableView.mj_header = header
        header.setTitle("Pull down for more :)", forState: MJRefreshState.Idle)
        header.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        header.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    func setFooterRefreshControl(){
        self.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NewsTableViewController.loadMoreData))
        self.tableView.mj_footer = footer
        footer.setTitle("Pull up for more :)", forState: MJRefreshState.Idle)
        footer.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    
    func setTableViewRowHeight(){
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }


    // MARK: - Table view data source
    
    
    func loadDataSource(){
        
        header.beginRefreshing()
        
        let url = NSURL(string: API_URL)
        let request = NSURLRequest(URL: url!)
        let LoadQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: LoadQueue) { (response, data, error) in
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        let NewsDataSource = json["list"]!["story"] as! NSArray
        
        let currentNewsData = self.loadCurrentNewsData(withNewsDataSource: NewsDataSource)
        self.DataSource = currentNewsData
        dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})

       }
        header.endRefreshing()
    }
    
    func loadMoreData(){
        
        footer.beginRefreshing()
        
        //update the api's url
        self.currentStartNumber += self.numberOfResults
        self.current_API_URL = "http://api.npr.org/query?id=\(id)&fields=\(fields)&startNum=\(currentStartNumber)&dateType=\(dateType)&output=\(output)&numResults=\(numberOfResults)&apiKey=\(apiKey)"
        
        let url = NSURL(string: current_API_URL)
        let request = NSURLRequest(URL: url!)
        let LoadQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: LoadQueue) { (response, data, error) in
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            let NewsDataSource = json["list"]!["story"] as! NSArray
            let currentNewsData = self.loadCurrentNewsData(withNewsDataSource: NewsDataSource)
            self.DataSource.addObjectsFromArray(currentNewsData as [AnyObject])
            dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})

        }
        footer.endRefreshing()
    }


    
    
    func loadCurrentNewsData(withNewsDataSource NewsDataSource: NSArray) -> NSMutableArray{
        let currentNewsData = NSMutableArray()
        
        for currentNews in NewsDataSource{
            let newsitem = NewsListItem()
            newsitem.title = currentNews["title"]!!["$text"] as! NSString
            print(newsitem.title as String)
            
            newsitem.teaser = currentNews["teaser"]!!["$text"] as! NSString
            
            let linkList = currentNews["link"] as! NSArray
            
            for link in linkList{
                if link["type"] as! NSString == "html"{
                    newsitem.link = link["$text"] as! NSString
                }
            }
            
            let imageList = currentNews["image"] as! NSArray
            
            for image in imageList{
                let imageCrop = image["crop"] as! NSArray
                for imageCropItem in imageCrop{
                    if imageCropItem["type"] as! NSString == "wide"{
                        newsitem.imageURL = image["crop"]!![2]["src"] as! NSString
                    }
                }
            }
            
            currentNewsData.addObject(newsitem)
            
        }
        return currentNewsData
    }

    //Initialize table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DataSource.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.NewsListIdentifier, forIndexPath: indexPath) as! NewsListTableViewCell
        let item = DataSource[indexPath.section] as! NewsListItem

        cell.NewsTitle.text = item.title as String
        cell.NewsTeaser.text = item.teaser as String
        cell.NewsLink = item.link as String

        if let url = NSURL(string: item.imageURL as String){
            cell.spinner?.startAnimating()
            cell.NewsImage.kf_setImageWithURL(url)
            if (cell.NewsImage != nil){
                cell.spinner?.stopAnimating()
            }
        }
        return cell
    }

    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowNewsContentIdentifier{
            if let nvc = segue.destinationViewController.contentViewController as? NewsContentViewController{
                let NewsLink = (sender as? NewsListTableViewCell)?.NewsLink
                nvc.News_URL = NewsLink!
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
