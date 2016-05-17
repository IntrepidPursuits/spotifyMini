//
//  GenreSelectTableViewController.swift
//  spotifyMini
//
//  Created by Tom OMalley on 5/17/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

class GenreSelectTableViewController : UITableViewController {

    var genres = [String]()
    let spotify = Spotify.manager

    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateTableViewWithGenres()
    }

    func populateTableViewWithGenres() {
        self.spotify.fetchAvailableGenreSeeds { result in
            if let error = result.error as? SpotifyError {
                self.presentErrorAlert(error)
            } else if let genres = result.value {
                self.genres = genres
                self.tableView.reloadData()
            }
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.ip_dequeueCell(indexPath)
        cell.textLabel?.text = self.genres[indexPath.row].capitalizedString
        return cell
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ip = self.tableView.indexPathForSelectedRow,
            let analysisVC = segue.destinationViewController as? AnalysisViewController {
            analysisVC.genre = self.genres[ip.row]
        }
    }
}
