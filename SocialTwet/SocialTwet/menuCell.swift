//
//  menuCell.swift
//  SocialTwet
//
//  Created by CongTruong on 11/4/16.
//  Copyright © 2016 congtruong. All rights reserved.
//

import UIKit

class menuCell: UITableViewCell {

    @IBOutlet weak var iconMenuImageView: UIImageView!
    @IBOutlet weak var cellNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
