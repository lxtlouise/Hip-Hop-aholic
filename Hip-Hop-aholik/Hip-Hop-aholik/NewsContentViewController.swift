//
//  NewsContentViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/16.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class NewsContentViewController: UIViewController, UIWebViewDelegate {

    var news_URL: String!
    private var newsContentHeader = MJRefreshNormalHeader()
    
    @IBOutlet weak var newsWebView: UIWebView!

    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)
        self.navigationItem.title = "News"
        
        self.addSpinnerToLeftNavigationItem()
        self.spinner.startAnimating()
        
        let item = UIBarButtonItem(title: "...", style: .Done, target: self, action: #selector(self.openActivityController(_:)))
        let titleTextAttributes: NSDictionary = [NSFontAttributeName: UIFont.boldSystemFontOfSize(28.0)]
        item.setTitleTextAttributes(titleTextAttributes as? [String : AnyObject], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = item
        
        self.newsWebView.delegate = self
        self.setWebHeaderRefreshControl()
        self.newsContentHeader.beginRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setWebHeaderRefreshControl(){
        
        self.newsContentHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(self.loadNewsContent))
        
        self.newsWebView.scrollView.mj_header = self.newsContentHeader
        newsContentHeader.stateLabel.textColor = UIColor.lightTextColor()
        newsContentHeader.setTitle("Pull down for more :)", forState: MJRefreshState.Idle)
        newsContentHeader.setTitle("Aight, release me now!", forState: MJRefreshState.Pulling)
        newsContentHeader.setTitle("I'm workin'...", forState: MJRefreshState.Refreshing)
    }
    
    private func addSpinnerToLeftNavigationItem(){
        self.spinner.color = UIColor.cyanColor()
        let barButton = UIBarButtonItem(customView: spinner)
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.setLeftBarButtonItem(barButton, animated: true)
    }

    
    func loadNewsContent(){
        let url = NSURL(string: news_URL)
        let newsRequest = NSURLRequest(URL: url!)
        self.newsWebView.loadRequest(newsRequest)
        
        self.newsContentHeader.endRefreshing()
    }
    
    func openActivityController(sender: UIButton){
        let acts = [NewsSafari()]
        if let url = NSURL(string: news_URL){
            let objectsToShare = [url]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: acts)
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypeMail, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks, UIActivityTypeSaveToCameraRoll, UIActivityTypeMessage]
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
        
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.spinner.stopAnimating()
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
