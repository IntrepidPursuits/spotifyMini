//
//  PopularSongTableViewCell.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/5/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import FontAwesomeKit
import Intrepid

class PopularTrackTableViewCell : UITableViewCell {

    var track: SPTTrack?

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton! {
        didSet {
            let moreIcon = FAKIonIcons.iosMoreIconWithSize(20).imageWithSize(CGSizeMake(18, 18))
            moreButton.setImage(moreIcon, forState: .Normal)
            self.layoutIfNeeded()
            moreButton.layer.cornerRadius = moreButton.ip_halfHeight
            moreButton.layer.borderWidth = 1.0
            moreButton.layer.borderColor = moreButton.tintColor.CGColor
        }
    }
}
