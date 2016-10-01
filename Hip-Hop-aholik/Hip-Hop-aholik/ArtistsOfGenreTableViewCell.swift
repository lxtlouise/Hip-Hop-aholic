//
//  ArtistsOfGenreTableViewCell.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/12.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistsOfGenreTableViewCell: UITableViewCell {
    @IBOutlet weak var artistOfGenreImage: UIImageView!
    @IBOutlet weak var artistOfGenreName: UILabel!
    
    @IBAction private func youtubeLog(sender: UIButton) {
        if let url = channelUrl{
            UIApplication.sharedApplication().openURL(url)
        }
    }
    var playlistId: String!
    var imageUrl: NSURL!
    var channelUrl: NSURL!
}
