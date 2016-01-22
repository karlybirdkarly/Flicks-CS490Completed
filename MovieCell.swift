//
//  MovieCell.swift
//  MovieViewer
//
//  Created by Karlygash Zhuginissova on 1/14/16.
//  Copyright © 2016 Karlygash Zhuginissova. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
