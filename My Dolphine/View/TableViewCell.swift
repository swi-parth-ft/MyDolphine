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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
