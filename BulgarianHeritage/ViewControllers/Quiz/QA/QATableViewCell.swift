//
//  QATableViewCell.swift
//  PAM
//
//  Created by Teodor Evgeniev Yanev on 14.08.18.
//  Copyright © 2018 Stamsoft. All rights reserved.
//

import UIKit
protocol QATableViewCellDelegate: class {
    func qaTableViewCell(_ qaTableViewCell: QATableViewCell, didSelect button: RadioButton)
}
class QATableViewCell: UITableViewCell {
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerButton: RadioButton!

    @IBAction func answerAction(_ sender: RadioButton) {
        delegate?.qaTableViewCell(self, didSelect: sender)
    }
    weak var delegate: QATableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension QATableViewCell: NibLoadableView { }
extension QATableViewCell: ReusableView { }

