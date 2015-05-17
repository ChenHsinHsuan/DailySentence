//
//  SentenceCellTableViewCell.swift
//  DailySentence
//
//  Created by Chen Hsin Hsuan on 2015/5/10.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import UIKit
import Spring
class SentenceTableViewCell: UITableViewCell {

    
    @IBOutlet weak var authorImageView: SpringImageView!
    @IBOutlet weak var authorLabel: SpringLabel!
    @IBOutlet weak var enLabel: SpringLabel!
    @IBOutlet weak var cnLabel: SpringLabel!
    @IBOutlet weak var createAtLabel: SpringLabel!
    @IBOutlet weak var favorButton: UIButton!
    @IBOutlet weak var favorImageView: SpringImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
