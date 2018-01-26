//
//  TaskInfoCell.swift
//  Project2-PMS
//
//  Created by LinChico on 1/25/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class TaskInfoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateImageView: UIImageView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var membersCollection: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
