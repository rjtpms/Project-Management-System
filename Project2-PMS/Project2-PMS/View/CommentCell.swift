//
//  CommentCell.swift
//  Project2-PMS
//
//  Created by LinChico on 1/25/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
