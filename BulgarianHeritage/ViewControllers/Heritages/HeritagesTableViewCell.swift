//
//  HeritagesTableViewCell.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 3.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

extension HeritagesTableViewCell: ReusableView { }
extension HeritagesTableViewCell: NibLoadableView { }

class HeritagesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
