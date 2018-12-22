//
//  FavoriteTableViewCell.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/24/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var dates: UITextView!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
