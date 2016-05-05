//
//  ArtistViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/5/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid
import FontAwesomeKit

class ArtistViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var artist: SPTArtist?

    @IBOutlet weak var artistHeaderView: ArtistHeaderView!
    @IBOutlet weak var shufflePlayButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Constraints
    @IBOutlet weak var headerImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistViewBottomConstraint: NSLayoutConstraint!

    var isShowingHeader = false

    // MARK: View Life Cycle

    override func viewDidLoad() {
        self.tableView.ip_registerCell(PopularTrackTableViewCell)
        self.tableView.rowHeight = 60
        self.makeNavBarTransparent()
        self.setupMoreBarButton()
    }

    // MARK: Actions

    func moreTapped() {
        print("will this ever do anything?")
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let shouldGrowHeader = yOffset < 0
        let shouldShowHeader = yOffset >= 250 && !self.isShowingHeader
        let shouldHideHeader = yOffset < 250 && self.isShowingHeader

        if shouldGrowHeader {
            self.animateHeaderView(withOffset: yOffset)
        } else {
            self.artistHeaderView.blurAlpha = 1.0
        }

        // FIXME: not working anymore :(
        if shouldShowHeader {
            self.isShowingHeader = true
            self.headerImageViewHeightConstraint.priority = 1
            self.artistViewBottomConstraint.priority = 999
            self.swapContainerViewAndScrollViewPositions()
        } else if shouldHideHeader {
            self.isShowingHeader = false
            self.headerImageViewHeightConstraint.priority = 999
            self.artistViewBottomConstraint.priority = 1
            self.swapContainerViewAndScrollViewPositions()
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

    // MARK: Animation Helpers

    func swapContainerViewAndScrollViewPositions() {
        if let scrollViewIndex = self.view.subviews.indexOf(self.scrollView),
            let artistHeaderViewIndex = self.view.subviews.indexOf(self.artistHeaderView) {
            self.view.exchangeSubviewAtIndex(scrollViewIndex, withSubviewAtIndex: artistHeaderViewIndex)
        }
    }

    func animateHeaderView(withOffset yOffset: CGFloat) {
        let originalConstant = 350 as CGFloat // FIXME: magic number?
        self.headerImageViewHeightConstraint.constant = originalConstant + (yOffset * -1)
        let affectedAlpha = 1.5 + (yOffset/100.0)
        self.artistHeaderView.blurAlpha = affectedAlpha
        self.navigationController?.navigationBar.alpha = affectedAlpha
        self.navigationController?.setNavigationBarHidden(affectedAlpha <= 0.1, animated: true)
    }

    // MARK: View Setup

    func makeNavBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }

    func setupMoreBarButton() {
        let iconSize = 40 as CGFloat
        let moreIcon = FAKIonIcons.iosMoreIconWithSize(iconSize).imageWithSize(CGSizeMake(iconSize, iconSize))
        let moreBarButton = UIBarButtonItem(image: moreIcon, style: .Plain, target: self, action: #selector(moreTapped))
        moreBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = moreBarButton
    }

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
        bottomBorder.heightAnchor.constraintEqualToConstant(0.5).active = true
        bottomBorder.leadingAnchor.constraintEqualToAnchor(header.leadingAnchor).active = true
        bottomBorder.trailingAnchor.constraintEqualToAnchor(header.trailingAnchor).active = true
        bottomBorder.bottomAnchor.constraintEqualToAnchor(header.bottomAnchor).active = true
        
        return header
    }
}
