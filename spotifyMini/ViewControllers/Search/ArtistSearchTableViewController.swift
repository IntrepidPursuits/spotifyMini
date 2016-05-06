//
//  TableViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/4/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit

class ArtistSearchTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SPTAuthViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var logInBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var session: SPTSession? {
        didSet {
            if let session = self.session {
                self.logInBarButton.enabled = !session.isValid() // FIXME: isValid() is lying
            }
        }
    }

    let cellIdentifier = "basicCell"
    var searchResults = [SPTPartialArtist]()
    var fullArtists = [SPTArtist]()

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(recieveSpotifyLogInNotification(_:)), name: AppReturnedFromSpotifyNotification, object: nil)
        self.checkForExistingSession()
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
        SPTSearch.performSearchWithQuery(searchBar.text, queryType: SPTSearchQueryType.QueryTypeArtist, offset: 0, accessToken: nil) { error, listPage in
            if let error = error {
                print(error.localizedDescription) //FIXME: throw application error
                return
            } else if let listPage = listPage as? SPTListPage,
                let items = listPage.items as? [SPTPartialArtist] {
                self.searchResults = items
                self.tableView.reloadData()
                let artistURIs = items.map { $0.uri }
                SPTArtist.artistsWithURIs(artistURIs, session: self.session, callback: { error, object in
                    if let error = error {
                        print("fetch SPTArtist error: \(error.localizedDescription)") // FIXME: throw application error
                    } else if let artists = object as? [SPTArtist] {
                        self.fullArtists = artists
                    }
                })
            }
        }
    }

    // MARK: SPTSession

    func checkForExistingSession() {
        if let sessionData = NSUserDefaults.standardUserDefaults().objectForKey(SpotifySessionUserDefaultsKey) as? NSData,
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession {
            self.session = session
        }
    }

    // MARK: Notification Handling

    func recieveSpotifyLogInNotification(notification:NSNotification) {
        self.dismissViewControllerAnimated(false, completion: nil)
        if let session = notification.userInfo?[SpotifySessionUserDefaultsKey] as? SPTSession {
            self.session = session
            self.logInBarButton.enabled = false
        } else if let error = notification.userInfo?["error"] as? NSError {
            print(error) // FIXME: handle this error
        }
    }

    // MARK: SPTAuthViewDelegate

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        // FIXME: make this an application error, handle it
    }

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        // this method is required, but i have no use for it ...
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        self.session = session
    }

    // MARK: Navigation 

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let cell = sender as? UITableViewCell,
            let ip = self.tableView.indexPathForCell(cell) {
            return self.fullArtists.indices.contains(ip.row)
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toArtistVC",
            let ip = self.tableView.indexPathForSelectedRow,
            let artistVC = segue.destinationViewController as? ArtistViewController {
            artistVC.artist = self.fullArtists[ip.row]
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
