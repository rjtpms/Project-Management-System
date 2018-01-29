//
//  TaskCell.swift
//  Project2-PMS
//
//  Created by LinChico on 1/24/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var finishedImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
