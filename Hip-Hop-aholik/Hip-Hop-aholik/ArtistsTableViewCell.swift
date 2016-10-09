//
//  ArtistsTableViewCell.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/10.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var artistImage: UIImageView!
    
    @IBOutlet weak var artistName: UILabel!
    
    
    @IBAction private func youtubeLogo(sender: UIButton) {
        if let url = channelUrl{
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    var playlistId: String!
    
    var imageUrl: NSURL!
    
    var channelUrl: NSURL!
}
