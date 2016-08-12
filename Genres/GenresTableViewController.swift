//
//  GenresTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/9.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class GenresTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitViewController?.delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self{
            if let agvc = secondaryViewController.contentViewController as? ArtistsOfGenreTableViewController where agvc.numberOfSections == 0{
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
    
    //initialize table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return genresTableData.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.GenresIdentifier, forIndexPath: indexPath) as! GenresTableViewCell
        cell.genreName.text = genresTableData[indexPath.section]
        return cell
    }
    
    
    // MARK: - Navigation
    // Segue from Genres to ArtistsOfGenre
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowArtistsOfGenreIdentifier{
            if let agvc = segue.destinationViewController.contentViewController as? ArtistsOfGenreTableViewController{
                let genreName = (sender as? GenresTableViewCell)?.genreName.text
                let item = artistsOfGenreDictionary[genreName!]!
                agvc.numberOfSections = item.count
                agvc.artistsOfGenreTableData = item
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
