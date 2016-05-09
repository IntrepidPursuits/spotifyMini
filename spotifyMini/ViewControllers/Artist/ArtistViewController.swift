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

    var partialArtist: SPTPartialArtist?
    var artist: SPTArtist?
    let spotify = Spotify.manager
    var topTracks = [SPTTrack]()
    var artistHeaderView = ArtistHeaderView.ip_fromNib()
    @IBOutlet weak var shufflePlayButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moreBarButton: UIBarButtonItem! {
        didSet {
            let iconSize = 40.0 as CGFloat
            self.moreBarButton.image = FAKIonIcons.iosMoreIconWithSize(iconSize).imageWithSize(CGSizeMake(iconSize, iconSize))
        }
    }

    var headerIsOnTop = false

    // MARK: View Life Cycle

    override func viewDidLoad() {
        self.tableView.ip_registerCell(PopularTrackTableViewCell)
        self.tableView.rowHeight = 60
        self.setupArtistHeaderView()
        self.fetchArtistAndTopTracks()
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        self.animateHeaderView(withOffset: yOffset)
        self.handleScrollingUpUnderNavBar(withOffset: yOffset)
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
        return self.topTracks.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.ip_dequeueCell(indexPath) as PopularTrackTableViewCell
        cell.numberLabel?.text = "\(indexPath.row+1)"
        cell.track = self.topTracks[indexPath.row]
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? self.headerForSection(withTitle: "popular") : nil
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.topTracks[indexPath.row]
        self.spotify.play(track) { error in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.presentErrorAlert(error)
        }
    }

    // MARK: View Helpers

    func handleScrollingUpUnderNavBar(withOffset yOffset: CGFloat) {
        let shouldBringHeaderToFront = yOffset >= 250 && !self.headerIsOnTop
        let shouldSendHeaderToBack = yOffset < 250 && self.headerIsOnTop
        if shouldBringHeaderToFront || shouldSendHeaderToBack {
            self.headerIsOnTop = !self.headerIsOnTop
            self.swapContainerViewAndScrollViewPositions()
        }
    }

    func animateHeaderView(withOffset yOffset: CGFloat) {
        let userIsPullingDown = yOffset <= 0
        if userIsPullingDown {
            let affectedAlpha = 1.5 + (yOffset/100.0)
            self.artistHeaderView.blurAlpha = affectedAlpha
            self.artistHeaderView.blurHeightConstraint.constant = 325 - yOffset
            self.navigationController?.navigationBar.alpha = affectedAlpha
            self.navigationController?.setNavigationBarHidden(affectedAlpha <= 0.1, animated: true)
        } else {
            self.artistHeaderView.blurAlpha = 1.0
        }
    }

    func swapContainerViewAndScrollViewPositions() {
        if let scrollViewIndex = self.view.subviews.indexOf(self.scrollView),
            let artistHeaderViewIndex = self.view.subviews.indexOf(self.artistHeaderView) {
            self.view.exchangeSubviewAtIndex(scrollViewIndex, withSubviewAtIndex: artistHeaderViewIndex)
        }
    }

    // MARK: View Setup

    func setupArtistHeaderView() {
        self.view.addSubview(self.artistHeaderView)
        self.artistHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self.artistHeaderView.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        self.artistHeaderView.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        self.artistHeaderView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true

        self.artistHeaderView.bottomAnchor.constraintGreaterThanOrEqualToAnchor(self.view.topAnchor, constant: 85).active = true
        let bottomToShufflePlayCenterY = self.artistHeaderView.bottomAnchor.constraintEqualToAnchor(self.shufflePlayButton.centerYAnchor)
        bottomToShufflePlayCenterY.priority = 750
        bottomToShufflePlayCenterY.active = true

        self.view.sendSubviewToBack(self.artistHeaderView)
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

    // MARK: Spotify

    func fetchArtistAndTopTracks() {
        if let partialArtist = self.partialArtist {
            self.spotify.fetchFullArtist(forPartialArtist: partialArtist) { result in
                if let artist = result.value {
                    self.artist = artist
                    self.artistHeaderView.artist = artist
                    self.fetchTopTracks()
                } else if let error = result.error as? SpotifyError {
                    self.presentErrorAlert(error)
                }
            }
        }
    }

    func fetchTopTracks() {
        if let artist = self.artist {
            self.spotify.fetchTopTracks(forArtist: artist, completion: { result in
                if let topTracks = result.value {
                    self.topTracks = topTracks
                    self.tableView.reloadData()
                } else if let error = result.error as? SpotifyError{
                    self.presentErrorAlert(error)
                }
            })
        }
    }
}
