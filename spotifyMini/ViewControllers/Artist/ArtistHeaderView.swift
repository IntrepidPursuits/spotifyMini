//
//  ArtistHeaderImageView.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/6/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

class ArtistHeaderView : UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var blurContainerView: UIView!

    var blurAlpha: CGFloat = 1 {
        didSet {
            blurContainerView.alpha = blurAlpha
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        NSBundle.mainBundle().loadNibNamed("ArtistHeaderView", owner: self, options: nil)
        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        self.view.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        self.view.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        self.view.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
        self.clipsToBounds = true
    }
}