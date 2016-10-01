//
//  File.swift
//  Hip-Hop-aholik
//
//  Created by 13560793366 on 16/9/27.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import Foundation

class WikiSafari: UIActivity{
    private var url: NSURL!
    override func activityTitle() -> String? {
        return "Open Wiki in Safari"
    }
    override func activityType() -> String? {
        return "Safari"
    }
    
    override func activityImage() -> UIImage? {
        return nil
    }
    override func performActivity() {
        if let wikiUrl = url{
            UIApplication.sharedApplication().openURL(wikiUrl)
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