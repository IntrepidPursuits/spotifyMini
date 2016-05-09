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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var blurContainerView: UIView!
    @IBOutlet weak var blurHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            self.followButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.followButton.layer.borderWidth = 0.5
            self.followButton.layer.cornerRadius = self.followButton.ip_halfHeight
        }
    }
    
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

    // MARK: Creation

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}