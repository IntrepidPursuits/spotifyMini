//
//  ArtistViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/5/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

class ArtistViewController: UIViewController, UIScrollViewDelegate {

    var artist: SPTArtist? {
        didSet {
//            if let artist = self.artist {
//                // TODO: write function set up views
//            }
        }
    }
    @IBOutlet weak var headerImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shufflePlayButton: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        // FIXME: there has to be a better place for this
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        print(yOffset)
        if yOffset <= 0 {
            let originalConstant = 350 as CGFloat // FIXME: magic number?
            self.headerImageViewHeight.constant = originalConstant + (yOffset * -1)
            self.checkIfNavBarShouldHide(withOffset: yOffset)
            // TODO: animate blur view opacity (also fade nav bar instead of hide)
        }
        let standardNavBarHeight = 60 as CGFloat
        let userHasScrolledUpFarEnough = yOffset > self.shufflePlayButton.frame.origin.y - standardNavBarHeight
        self.shufflePlayButton.hidden = userHasScrolledUpFarEnough
        // self.shufflePlayHeader.hidden = userHasScrolledUpFarEnough
    }

    func checkIfNavBarShouldHide(withOffset yOffset: CGFloat) {
        let threshold = -100 as CGFloat
        let navBarHidden = self.navigationController?.navigationBarHidden
        if yOffset < threshold && (navBarHidden == false) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if yOffset > threshold  && (navBarHidden == true) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    // MARK: UIStatusBar

    override func prefersStatusBarHidden() -> Bool {
        return self.navigationController?.navigationBarHidden ?? false
    }

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }

    // MARK: UITableViewDataSource
    
}