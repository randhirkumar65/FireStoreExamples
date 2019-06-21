//
//  ItemCell.swift
//  FireStoreDemo
//
//  Created by Randhir Kumar on 07/05/19.
//  Copyright © 2019 Randhir Kumar. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak private var aNameLabel: UILabel!
    @IBOutlet weak private var aIdLabel: UILabel!
    @IBOutlet weak private var aDurationabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configCell(with item: ProjectDataModel) {
        self.aNameLabel.text = item.projectName
        self.aIdLabel.text = item.projectID
        self.aDurationabel.text = item.projectDuration
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
