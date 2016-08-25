//
//  NewsContentViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/16.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class NewsContentViewController: UIViewController, UIWebViewDelegate {

    var News_URL = String()
    var NewsContentHeader = MJRefreshNormalHeader()
    let application = UIApplication.sharedApplication()
    

    @IBOutlet weak var NewsContent: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "News"
        self.NewsContent?.delegate = self
        self.application.networkActivityIndicatorVisible = true
        self.setWebHeaderRefreshControl()
        self.NewsContentHeader.beginRefreshing()//Begin refreshing and call function loadNews().
        
    }

    func setWebHeaderRefreshControl(){
        self.NewsContentHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NewsContentViewController.loadNews))
        self.NewsContent.scrollView.mj_header = self.NewsContentHeader
        NewsContentHeader.stateLabel.textColor = UIColor.lightTextColor()
        NewsContentHeader.setTitle("Pull down for more :)", forState: MJRefreshState.Idle)
        NewsContentHeader.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        NewsContentHeader.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNews(){

        let url = NSURL(string: News_URL)
        let newsRequest = NSURLRequest(URL: url!)
        NewsContent.loadRequest(newsRequest)
        print(url)
        
        self.NewsContentHeader.endRefreshing()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
