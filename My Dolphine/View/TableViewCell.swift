//
//  TableViewCell.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemQuantity: UILabel!
    @IBOutlet weak var CheckButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    
    var infoButtonAction : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        infoButton.setTitle("", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func infoButtonClicked(_ sender: Any) {
        infoButtonAction?()
    }
}
