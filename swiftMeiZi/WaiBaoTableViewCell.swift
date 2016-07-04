//
//  WaiBaoTableViewCell.swift
//  swiftMeiZi
//
//  Created by teddy on 6/21/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit

class WaiBaoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var meatLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
