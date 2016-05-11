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

    var track: SPTTrack? {
        didSet {
            if let track = self.track {
                self.trackTitleLabel.text = track.name
            }
        }
    }

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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
                let originalBGColor = self.contentView.backgroundColor
                UIView.animateWithDuration(0.1, animations: {
                    self.trackTitleLabel.textColor = UIColor.greenColor()
                    self.contentView.backgroundColor = originalBGColor?.colorWithAlphaComponent(0.95)
                    }, completion: { _ in
                        self.contentView.backgroundColor = originalBGColor
                })
        } else {
            self.trackTitleLabel.textColor = UIColor.whiteColor()
        }
    }
}
