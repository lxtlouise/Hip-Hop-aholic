//
//  NewsListTableViewCell.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/15.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class NewsListTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsTeaser: UILabel!
    @IBOutlet weak var newsStoryDate: UILabel!
    
    var newsLink: String!
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
