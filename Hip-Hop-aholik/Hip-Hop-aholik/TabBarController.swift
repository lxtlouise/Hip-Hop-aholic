//
//  TabBarController.swift
//  hiphop
//
//  Created by 13560793366 on 16/9/11.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = self.tabBar.items
        for item in items! as [UITabBarItem]{
            let tabBarAttribute = NSDictionary(object: UIColor.cyanColor(), forKey: NSForegroundColorAttributeName)
            item.setTitleTextAttributes(tabBarAttribute as? [String : AnyObject], forState: UIControlState.Selected)
        }
        
        self.tabBar.tintColor = UIColor.cyanColor()
        self.tabBar.barTintColor = UIColor.blackColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
