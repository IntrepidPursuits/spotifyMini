//
//  ArtistHeaderImageView.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/6/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Kingfisher

class ArtistHeaderView : UIView {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView! {
        didSet {
            self.profileImageView.layer.cornerRadius = 60.0
        }
    }
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var blurImageView: UIImageView!
    @IBOutlet private weak var blurContainerView: UIView!
    @IBOutlet private weak var followButton: UIButton! {
        didSet {
            self.followButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.followButton.layer.borderWidth = 0.5
            self.followButton.layer.cornerRadius = self.followButton.ip_halfHeight
        }
    }
    @IBOutlet weak var blurHeightConstraint: NSLayoutConstraint!

    var artist: SPTArtist? {
        didSet {
            if let artist = self.artist {
                nameLabel.text = artist.name
                if let imageURL = artist.largestImage?.imageURL {
                    profileImageView.kf_setImageWithURL(imageURL, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                        self.headerImageView.image = image
                        self.blurImageView.image = image
                    })
                }
            }
        }
    }

    var blurAlpha: CGFloat = 1 {
        didSet {
            blurContainerView.alpha = blurAlpha
        }
    }

    var headerHeight: CGFloat = ArtistHeaderHeightLarge {
        didSet {
            self.blurHeightConstraint.constant = self.headerHeight
            if let heightConstraint = self.profileImageView.ip_heightConstraint {
                if self.headerHeight == ArtistHeaderHeightSmall {
                    heightConstraint.constant = 90.0
                } else {
                    heightConstraint.constant = 120
                }
                self.profileImageView.layer.cornerRadius = heightConstraint.constant / 2
            }
        }
    }

    // MARK: Creation

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
