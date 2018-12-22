//
//  UpcomingTableViewCell.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/21/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit

class UpcomingTableViewCell: UITableViewCell {

    @IBOutlet weak var upcomingEvtView: UIView!
    @IBOutlet weak var uevtName: UITextView!
    @IBOutlet weak var uevtArtist: UITextView!
    @IBOutlet weak var uevtDate: UITextView!
    @IBOutlet weak var uevtType: UITextView!
    var uri = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
