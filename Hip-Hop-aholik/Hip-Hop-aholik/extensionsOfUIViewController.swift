//
//  extensionOfUIViewController.swift
//  Hip-Hop-aholik
//
//  Created by 13560793366 on 16/9/30.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import Foundation

extension UIViewController{
    
    var contentViewController: UIViewController{
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }else{
            return self
        }
        
    }
    
    func changeNavigationBarTextColor(forNavController navController: UINavigationController){
        let nav = navController as UINavigationController
        let navigationTitleAttribute = NSDictionary(object: UIColor.cyanColor(), forKey: NSForegroundColorAttributeName)
        nav.navigationBar.titleTextAttributes = navigationTitleAttribute as? [String : AnyObject]
        nav.navigationBar.barTintColor = UIColor.blackColor()
        nav.navigationBar.tintColor = UIColor.cyanColor()
    }
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int?, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as? NSHTTPURLResponse)?.statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    
}


