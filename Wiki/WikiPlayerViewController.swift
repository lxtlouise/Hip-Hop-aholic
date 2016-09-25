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
    var playVars: Dictionary = [
        "origin":"http://www.youtube.com",
        "playsinline":"1",
        "showinfo":"0"
    ]
    

    @IBAction func youtubeLogo(sender: UIButton) {
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
        playerView.loadWithVideoId(videoId, playerVars: self.playVars)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
