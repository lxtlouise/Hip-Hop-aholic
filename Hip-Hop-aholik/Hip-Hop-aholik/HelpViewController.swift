//
//  HelpViewController.swift
//  Hip-Hop-aholik
//
//  Created by 13560793366 on 16/9/27.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var helpInfoTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.helpInfoTableView?.delegate = self
        self.helpInfoTableView?.dataSource = self
        self.helpInfoTableView.estimatedRowHeight = helpInfoTableView.rowHeight
        self.helpInfoTableView.rowHeight = UITableViewAutomaticDimension

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpInfoArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.HelpInformationIdentifier) as! HelpInfoTableViewCell
        let helpInfo = helpInfoArray[indexPath.row]
        cell.helpInformation.text = helpInfo
        return cell
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
