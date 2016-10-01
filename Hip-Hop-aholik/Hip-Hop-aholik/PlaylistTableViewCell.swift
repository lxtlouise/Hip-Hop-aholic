//
//  PlaylistTableViewCell.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/20.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var videoImage: UIImageView!
    
    @IBOutlet weak var videoTitle: UILabel!
    
    var videoId: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
