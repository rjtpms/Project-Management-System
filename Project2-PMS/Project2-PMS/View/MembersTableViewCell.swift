//
//  MembersTableViewCell.swift
//  Project2-PMS
//
//  Created by LinChico on 1/26/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class MembersTableViewCell: UITableViewCell {

    @IBOutlet weak var membersCollection: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
