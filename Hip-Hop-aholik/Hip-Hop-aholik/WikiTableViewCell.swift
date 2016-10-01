//
//  WikiTableViewCell.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/29.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class WikiTableViewCell: UITableViewCell {

    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var videoTitle: UILabel!
    
    @IBAction private func youtubeLogo(sender: UIButton) {
        if let id = videoId{
            let url = "https://www.youtube.com/watch?v=\(id)"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
    
    var videoId: String!
    var channelTag: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
