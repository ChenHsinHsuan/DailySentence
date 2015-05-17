//
//  AdTableViewCell.swift
//  DailySentence
//
//  Created by Chen Hsin Hsuan on 2015/5/16.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdTableViewCell: UITableViewCell {

    @IBOutlet weak var AdBannerView: GADBannerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
