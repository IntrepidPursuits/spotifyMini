//
//  TableViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/4/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit

class ArtistSearchTableViewController: UIViewController, SPTAuthViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var logInBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    let spotify = Spotify.manager
    let cellIdentifier = "basicCell"
    var searchResults = [Artist]()

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(recieveSpotifyLogInNotification(_:)), name: AppReturnedFromSpotifyNotification, object: nil)
        self.makeNavBarTransparent()
    }

    // MARK: Actions

    @IBAction func logInTapped(sender: AnyObject) {
        let spotifyLogInVC = SPTAuthViewController.authenticationViewController()
        spotifyLogInVC.delegate = self
        spotifyLogInVC.modalPresentationStyle = .OverCurrentContext
        spotifyLogInVC.modalTransitionStyle = .CrossDissolve
        self.presentViewController(spotifyLogInVC, animated: false, completion: nil)
    }

    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let artist = self.searchResults[indexPath.row]
        cell.textLabel?.text = artist.name
        return cell
    }

    // MARK: UISearchBarDelegate

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchBar.resignFirstResponder()
            self.spotify.searchForArtists(withQuery: text) { result in
                if let partialArtists = result.value {
                    self.searchResults = partialArtists
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: Notification Handling

    func recieveSpotifyLogInNotification(notification: NSNotification) {
        self.dismissViewControllerAnimated(false, completion: nil)
        if notification.userInfo?[SpotifyLogInErrorUserInfoKey] != nil {
            self.presentErrorAlert(.LogInFailed)
        }
    }

    // MARK: SPTAuthViewDelegate

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        self.presentErrorAlert(.LogInFailed)
    }

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        // this method is required, but i have no use for it ...
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        self.spotify.session = session
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toArtistVC",
            let ip = self.tableView.indexPathForSelectedRow,
            let artistVC = segue.destinationViewController as? ArtistViewController {
            artistVC.artist = self.searchResults[ip.row]
        }
    }
    
    // MARK: Navigation Bar
    
    func makeNavBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
}
