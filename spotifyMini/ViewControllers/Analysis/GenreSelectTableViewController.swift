//
//  GenreSelectTableViewController.swift
//  spotifyMini
//
//  Created by Tom OMalley on 5/17/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import RealmSwift

class GenreSelectTableViewController : UITableViewController {

    var genres = [Genre]()
    let spotify = Spotify.manager

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadGenresFromRealm()
        self.loadGenresFromSpotify()
    }

    // create any genre's that we dont already have
    func loadGenresFromSpotify() {
        self.spotify.fetchAvailableGenreSeeds { result in
            if let error = result.error as? SpotifyError {
                self.presentErrorAlert(error)
            } else if let genreStrings = result.value {
                self.updateRealmGenresIfNecessary(withGenreStrings: genreStrings)
            }
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.ip_dequeueCell(indexPath)
        cell.textLabel?.text = self.genres[indexPath.row].stringValue.capitalizedString
        return cell
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ip = self.tableView.indexPathForSelectedRow,
            let analysisVC = segue.destinationViewController as? AnalysisViewController {
            analysisVC.genre = self.genres[ip.row]
        }
    }

    // MARK: Realm

    func loadGenresFromRealm() {
        let realm = try! Realm()
        self.genres = realm.objects(Genre).map { $0 }
        self.tableView.reloadData()
    }

    func updateRealmGenresIfNecessary(withGenreStrings genreStrings: [String]) {
        let realm = try! Realm()
        let storedGenres = realm.objects(Genre)
        genreStrings.forEach { string in
            let matchingGenreObjects = storedGenres.filter { $0.stringValue == string }
            if matchingGenreObjects.isEmpty {
                try! realm.write {
                    realm.add(Genre(string: string))
                }
                self.loadGenresFromRealm()
            }
        }
    }
}
