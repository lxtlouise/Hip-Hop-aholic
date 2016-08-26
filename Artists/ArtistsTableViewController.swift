//
//  ArtistsTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/9.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistsTableViewController: UITableViewController, UISplitViewControllerDelegate{
    
    var sectionHeaders = [String]()
    
    func setSectionHeaders(){
    for i in 0...24{
        sectionHeaders.append(String(tableData[i][0][tableData[i][0].startIndex]))
    }
}
    
    
    
    var indexes=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#",]
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self{
            if let avc = secondaryViewController.contentViewController as? ArtistInfoViewController where avc.name == ""{
            return true
            }
        }
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    


    // MARK: - Table view data source
    
    //click the cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(tableData[indexPath.section][indexPath.row])")
    }
  
    //indexes
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var indexes = [String]()
        for i in 0...25{
            let ch = String(format:"%c", i+65)
            indexes.append(ch)
        }
        return indexes
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var  tbIndex: Int = 0
        
        for character in indexes{
            if character == title{
                return tbIndex
            }
            tbIndex += 1
        }
        return 0
    }

    //initialize table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableData.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return indexes[section]
    }
    
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.ArtistsIdentifier, forIndexPath: indexPath) as! ArtistsTableViewCell
        let item = tableData[indexPath.section][indexPath.row]
        cell.artistName.text = item[0]
        cell.artistImage.image = UIImage(named: item[1])
        cell.artistImage.layer.cornerRadius = cell.artistImage.frame.size.width/2
        cell.artistImage.clipsToBounds = true
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowArtistInfoIdentifier{
            if let artistInfovc = segue.destinationViewController.contentViewController as? ArtistInfoViewController{
                let name = (sender as? ArtistsTableViewCell)!.artistName.text
                artistInfovc.navigationItem.title = name!
                artistInfovc.image = UIImage(named: name!)!
                artistInfovc.name = name!
                artistInfovc.genres = artistInfoData.artistGenresDictionary[name!]!
                artistInfovc.wikiTitle = artistInfoData.artistWikiDictionary[name!]!
                artistInfovc.channelName = "\(artistsChannelData[name!]!)"
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
   
}

extension UIViewController{
    var contentViewController: UIViewController{
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }else{
            return self
        }
        
    }
}
