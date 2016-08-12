//
//  ArtistInfoViewController.swift
//  hiphop
//
//  Created by 13560793366 on 16/8/11.
//  Copyright © 2016年 13560793366. All rights reserved.
//

import UIKit

class ArtistInfoViewController: UIViewController{
    
    
    @IBOutlet weak var artistInfoImage: UIImageView!
    @IBOutlet weak var artistInfoName: UILabel!
    @IBOutlet weak var artistInfoGenres: UITextView!
    @IBOutlet weak var artistInfoIntroduction: UITextView!

    var image: UIImage = UIImage()
    var name: String = String()
    var genres: String = String()
    var intro: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.artistInfoImage.image = image
        self.artistInfoName.text = name
        self.artistInfoGenres.text = genres
        self.artistInfoIntroduction.text = intro
    }
    
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
