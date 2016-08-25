//
//  NewsListTableViewCell.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/15.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class NewsListTableViewCell: UITableViewCell {

    @IBOutlet weak var NewsImage: UIImageView!
    @IBOutlet weak var NewsTitle: UILabel!
    @IBOutlet weak var NewsTeaser: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var NewsLink = String()
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
