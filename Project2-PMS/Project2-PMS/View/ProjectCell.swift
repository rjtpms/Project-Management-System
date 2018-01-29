//
//  ProjectCell.swift
//  Project2-PMS
//
//  Created by Mark on 1/28/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {
	@IBOutlet weak var projectName: UILabel!
	@IBOutlet weak var projectStartDate: UILabel!
	@IBOutlet weak var projectDueDate: UILabel!
	@IBOutlet weak var daysLeft: UILabel!
	@IBOutlet weak var startLabel: UILabel!
	@IBOutlet weak var endLabel: UILabel!
	
	private let cellLFont = UIFont(name: "Avenir-Heavy", size: 18)
	private let cellmFont = UIFont(name: "Avenir-Heavy", size: 12)
	private let cellsFont = UIFont(name: "Avenir", size: 10)
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		projectName.font = cellLFont
		projectStartDate.font = cellmFont
		projectDueDate.font = cellmFont
		startLabel.font = cellsFont
		endLabel.font = cellsFont
		daysLeft.font = cellmFont
	}
	
	func configureCell(with project: Project, and countdownDays: Int) {
		projectName.text = project.name
		projectStartDate.text = project.startDate.dateString
		projectDueDate.text = project.endDate.dateString
		daysLeft.text = "\(countdownDays)"
		self.accessoryType = .disclosureIndicator
	}
}
