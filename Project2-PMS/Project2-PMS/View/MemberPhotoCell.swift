//
//  MemberPhotoCell.swift
//  Project2-PMS
//
//  Created by Mark on 1/27/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit
import SDWebImage

class MemberPhotoCell: UICollectionViewCell {
	@IBOutlet weak var memberPhoto: UIImageView!
	
	var photoUrl: URL! {
		didSet {
			if photoUrl != nil {
				memberPhoto.sd_setImage(with: photoUrl, completed: nil)
			} else {
				memberPhoto.image = #imageLiteral(resourceName: "placeholder")
			}
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		memberPhoto.layer.cornerRadius = memberPhoto.frame.size.width / 2
		memberPhoto.clipsToBounds = true
		memberPhoto.layer.masksToBounds = true
	}
	
}
