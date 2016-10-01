//
//  WikiPlayerViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/30.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class WikiPlayerViewController: UIViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    var videoId: String!
    private var playVars: Dictionary = [
        "origin":"http://www.youtube.com",
        "playsinline":"1",
        "showinfo":"0"
    ]
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

    @IBAction private func youtubeLogo(sender: UIButton) {
        if let id = videoId{
            let urlString = "https://www.youtube.com/watch?v=\(id)"
            let url = NSURL(string: urlString)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let nav = self.navigationController
        self.changeNavigationBarTextColor(forNavController: nav!)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        self.addSpinnerToLeftNavigationItem()
        
        self.spinner.startAnimating()
        playerView.setPlaybackQuality(YTPlaybackQuality.Small)
        playerView.loadWithVideoId(videoId, playerVars: self.playVars)
        
        
        playerView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addSpinnerToLeftNavigationItem(){
        self.spinner.color = UIColor.cyanColor()
        let barButton = UIBarButtonItem(customView: spinner)
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.setLeftBarButtonItem(barButton, animated: true)
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        self.spinner.stopAnimating()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowHelpIdentifier{
            segue.destinationViewController.contentViewController as! HelpViewController
            
            
        }
    }
    

}
