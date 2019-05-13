//
//  ScoresTableViewCell.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 10.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

extension ScoresTableViewCell: ReusableView { }
extension ScoresTableViewCell: NibLoadableView { }

class ScoresTableViewCell: UITableViewCell {

    @IBOutlet var labelsCollection: [UILabel]!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
