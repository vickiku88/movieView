//
//  TableViewCell.swift
//  movieViewer
//
//  Created by victoria_ku on 6/8/17.
//  Copyright © 2017 victoria_ku. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {


  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var overview: UILabel!
  @IBOutlet weak var imgView: UIImageView!

  

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
