//
//  File.swift
//  hiphop
//
//  Created by 13560793366 on 16/9/24.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import Foundation

class NewsSafari: UIActivity{
    
    private var url: NSURL!
    override func activityTitle() -> String? {
        return "Open in Safari"
    }
    override func activityType() -> String? {
        return "Safari"
    }
    
    override func activityImage() -> UIImage? {
        return nil
    }
    override func performActivity() {
        if let newsUrl = url{
            UIApplication.sharedApplication().openURL(newsUrl)
        }
    }
    override func activityViewController() -> UIViewController? {
        
        return nil
    }
        
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for item in activityItems{
            if item is NSURL{
                self.url = item as! NSURL
            }
        }
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for item in activityItems{
            if item is NSURL{
                return true
            }
        }
        return false
    }
}