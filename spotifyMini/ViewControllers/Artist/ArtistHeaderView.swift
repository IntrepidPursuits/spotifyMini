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
        self.view.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        self.view.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        self.view.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
        self.view.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        self.clipsToBounds = true
    }
}