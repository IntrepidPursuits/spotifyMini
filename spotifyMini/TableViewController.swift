//
//  TableViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/4/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    let cellIdentifier = "basicCell"
    var searchResults = [SPTJSONObjectBase]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        if let track = self.searchResults[indexPath.row] as? SPTPartialTrack {
            cell.textLabel?.text = track.name
            let artist = track.artists.first as? SPTPartialArtist
            cell.detailTextLabel?.text = artist?.name
        }

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
        // TODO: implement search function
        SPTSearch.performSearchWithQuery(searchBar.text, queryType: SPTSearchQueryType.QueryTypeTrack, offset: 0, accessToken: nil) { error, listPage in
            if let error = error {
                print(error.localizedDescription) //FIXME: throw application error
                return
            } else if let listPage = listPage as? SPTListPage,
                let items = listPage.items as? [SPTPartialTrack] {
                self.searchResults = items
                self.tableView.reloadData()
            }
        }
    }
}
