//
//  DetailViewController.swift
//  movieViewer
//
//  Created by victoria_ku on 6/8/17.
//  Copyright © 2017 victoria_ku. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var postImgView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var infoView: UIView!

  var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

      scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y+infoView.frame.size.height)


      let title = movie["title"] as! String
      titleLabel.text = title
      titleLabel.sizeToFit()
      overviewLabel.text = movie["overview"]
 as? String
      overviewLabel.sizeToFit()

      let posterpath = movie?["poster_path"] as! String
      let baseURL = "https://image.tmdb.org/t/p/w500"
      let imageURL = NSURL(string:baseURL + posterpath)
      postImgView.setImageWith(imageURL! as URL)





      
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

