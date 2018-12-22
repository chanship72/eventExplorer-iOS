//
//  ResultTableViewCell.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/19/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var favorite: UIButton!
    @IBOutlet weak var dates: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
