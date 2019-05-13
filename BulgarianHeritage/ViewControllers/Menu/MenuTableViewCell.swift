//
//  MenuTableViewCell.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 21.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

extension MenuTableViewCell: ReusableView { }
extension MenuTableViewCell: NibLoadableView { }

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
