//
//  ArtistViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/5/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid

class ArtistViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var artist: SPTArtist?

    let cellIdentifier = "PopularTrackCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shufflePlayButton: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        
        self.tableView.ip_registerCell(PopularTrackTableViewCell)
        self.tableView.rowHeight = 60
        // FIXME: there has to be a better place for this
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if yOffset <= 0 {
            let originalConstant = 350.0 as CGFloat // FIXME: magic number?
            self.headerImageViewHeight.constant = originalConstant + -yOffset
            self.checkIfNavBarShouldHide(withOffset: yOffset)
            // TODO: animate blur view opacity (also fade nav bar instead of hide)
        }
        let standardNavBarHeight = 60.0 as CGFloat
        let userHasScrolledUpFarEnough = yOffset > self.shufflePlayButton.frame.origin.y - standardNavBarHeight
        self.shufflePlayButton.hidden = userHasScrolledUpFarEnough // FIXME: don't hide, use <= constraints to pin instead
    }

    func checkIfNavBarShouldHide(withOffset yOffset: CGFloat) {
        let threshold = -100.0 as CGFloat
        let scrolledPastThreshold = yOffset < threshold
        self.navigationController?.setNavigationBarHidden(scrolledPastThreshold, animated: true)
    }

    // MARK: UIStatusBar

    override func prefersStatusBarHidden() -> Bool {
        return self.navigationController?.navigationBarHidden ?? false
    }

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 // FIXME: magic number
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.ip_dequeueCell(indexPath) as PopularTrackTableViewCell
        cell.numberLabel?.text = "\(indexPath.row+1)"
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return self.headerForSection(withTitle: "popular") // TODO: enum?
        default:
            return nil
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }

    // MARK: Helpers

    func headerForSection(withTitle title: String) -> UIView {
        let header = UIView()
        let titleLabel = UILabel()
        header.addSubview(titleLabel)
        titleLabel.text = title.uppercaseString
        titleLabel.textColor = UIColor.lightTextColor()
        titleLabel.font = UIFont.systemFontOfSize(13)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor, constant: 16).active = true
        titleLabel.centerYAnchor.constraintEqualToAnchor(header.centerYAnchor).active = true

        let bottomBorder = UIView()
        header.addSubview(bottomBorder)
        bottomBorder.backgroundColor = UIColor.lightGrayColor()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.heightAnchor.constraintEqualToConstant(1.0).active = true
        bottomBorder.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor).active = true
        bottomBorder.trailingAnchor.constraintEqualToAnchor(header.trailingAnchor).active = true
        bottomBorder.bottomAnchor.constraintEqualToAnchor(header.bottomAnchor).active = true

        return header
    }
}
