//
//  ArtistsOfGenreTableViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/12.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistsOfGenreTableViewController: UITableViewController {
    
    var numberOfSections:Int = 0
    
    var artistsOfGenreTableData: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    //intialize table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardIdentifiers.ArtistsOfGenreIdentifier, forIndexPath: indexPath) as! ArtistsOfGenreTableViewCell
        let name = artistsOfGenreTableData[indexPath.section]
        cell.artistOfGenreName.text = name
        cell.artistOfGenreImage.image = UIImage(named: name)
        return cell
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryboardIdentifiers.ShowArtistOfGenreInfoIdentifier{
            if let artistInfovc = segue.destinationViewController.contentViewController as? ArtistInfoViewController{
                let name = (sender as? ArtistsOfGenreTableViewCell)!.artistOfGenreName.text
                artistInfovc.navigationItem.title = name
                artistInfovc.image = UIImage(named: name!)!
                artistInfovc.name = name!
                artistInfovc.genres = artistInfoData.artistGenresDictionary[name!]!
                artistInfovc.intro = artistInfoData.artistIntroDictionary[name!]!
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
