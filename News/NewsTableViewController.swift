//
//  NewsTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/9.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    var API_URL = "http://api.npr.org/query?id=10005&fields=title,teaser,storyDate,byline,image,textWithHtml&dateType=story&output=JSON&numResults=10&apiKey=MDI1ODYyMTQzMDE0NzExMzk0NjdiNzUxYg000"
    var DataSource:[NewsListItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self, action: #selector(NewsTableViewController.loadDataSource), forControlEvents: UIControlEvents())
        self.refreshControl = refreshControl
        loadDataSource()
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func loadDataSource(){
        refreshControl?.beginRefreshing()
        let url = NSURL(string: API_URL)
        let request = NSURLRequest(URL: url!)
        let LoadQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: LoadQueue) { (response, data, error) in
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        
        let NewsDataSource = json["list"]!["story"] as! NSArray
        
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
                    
            self.DataSource.append(newsitem)
            dispatch_async(dispatch_get_main_queue(), {self.tableView.reloadData()})
       }
       }
        refreshControl?.endRefreshing()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DataSource.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.NewsListIdentifier, forIndexPath: indexPath) as! NewsListTableViewCell
        let item = DataSource[indexPath.section]
        cell.NewsTitle.text = item.title as String
        cell.NewsTeaser.text = item.teaser as String
        cell.NewsLink = item.link as String
        let url = NSURL(string: item.imageURL as String)
        let request = NSURLRequest(URL: url!)
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) in
            let image = UIImage(data: data!)
            dispatch_async(dispatch_get_main_queue(), {
                cell.NewsImage.image = image
                cell.NewsImage.contentMode = UIViewContentMode.ScaleAspectFit
            })
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
