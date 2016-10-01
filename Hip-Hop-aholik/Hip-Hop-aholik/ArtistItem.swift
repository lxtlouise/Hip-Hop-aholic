//
//  ArtistItem.swift
//  hiphop
//
//  Created by 13560793366 on 16/9/14.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import Foundation

public class ArtistItem{
   
    var artistChannelName: String!
    var artistChannelID: String!
    var artistGenres: String!
    var artistWikiTitle: String!
    
    init(withChannelName channelName: String?, andChannelID channelID: String?, andGenres genres: String, andWikiTitle wikiTitle: String){
        self.artistChannelName = channelName
        self.artistChannelID = channelID
        self.artistGenres = genres
        self.artistWikiTitle = wikiTitle
    }
}
