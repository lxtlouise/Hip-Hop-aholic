//
//  PlayerViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/23.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var playerView: YTPlayerView!
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    @IBAction private func youtubeLogo(sender: AnyObject) {
        if let id = videoId{
            let urlString = "https://www.youtube.com/watch?v=\(id)"
            let url = NSURL(string: urlString)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    var videoId: String!
    
    
    private var playVar: Dictionary = [
        "origin":"http://www.youtube.com",
        "playsinline":"1",
        "showinfo":"0"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSpinnerToLeftNavigationItem()
        self.spinner.startAnimating()
        
        self.playerView.setPlaybackQuality(YTPlaybackQuality.Auto)
        self.playerView.loadWithVideoId(self.videoId, playerVars: self.playVar)
        self.playerView.delegate = self
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowHelpIdentifier{
            segue.destinationViewController.contentViewController as! HelpViewController
                
            
        }
    }
    
    /*override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
        if identifier == StoryboardIdentifiers.ShowHelpIdentifier{
            
        }
    }*/
    

}
