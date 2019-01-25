//
//  JournalTableViewCell.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/24/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class JournalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageForEntry: UIImageView!
    @IBOutlet weak var titleForEntry: UILabel!
    @IBOutlet weak var dateForEntry: UILabel!
    @IBOutlet weak var entryText: UILabel!
    @IBOutlet weak var smilieImage: UIImageView!
    
    
    static let reuseIdentifier = "JournalCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
