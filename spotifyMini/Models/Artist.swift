//
//  Artist.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/10/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid

let ArtistFetchedFullInfoNotification = "ArtistFullInfoFetched"
let ArtistFetchedTopTracksNotification = "ArtistTopTracksFetched"
let ArtistNotificationErrorUserInfoKey = "ArtistNotificationError"

class Artist {

    private let partialArtist: SPTPartialArtist
    private var fullArtist: SPTArtist?
    private let spotify = Spotify.manager

    // MARK: Public Properties

    var name: String {
        return self.partialArtist.name
    }

    var hasFullInfo: Bool {
        return self.fullArtist != nil
    }

    var imageURL: NSURL? {
        return self.fullArtist?.largestImage?.imageURL
    }

    var topTracks: [SPTTrack]?

    // MARK: Creation

    init(partialArtist: SPTPartialArtist, fullArtist: SPTArtist? = nil) {
        self.partialArtist = partialArtist
        self.fullArtist = fullArtist
    }

    // MARK: Fetching

    func fetchFullInfo() {
        self.spotify.fetchFullArtist(forPartialArtist: self.partialArtist) { result in
            self.fullArtist = result.value
            var userInfo: [String:AnyObject]?
            if let error = result.error as? SpotifyError {
                userInfo = [ArtistNotificationErrorUserInfoKey : NSError(spotifyError: error)]
            }
            NSNotificationCenter.defaultCenter().postNotificationName(ArtistFetchedFullInfoNotification, object: self, userInfo: userInfo)
        }
    }

    func fetchTopTracks() {
        if let fullArtist = self.fullArtist {
            self.spotify.fetchTopTracks(forArtist: fullArtist, completion: { result in
                self.topTracks = result.value
                var userInfo: [String:AnyObject]?
                if let error = result.error as? SpotifyError {
                    userInfo = [ArtistNotificationErrorUserInfoKey : NSError(spotifyError: error)]
                }
                NSNotificationCenter.defaultCenter().postNotificationName(ArtistFetchedTopTracksNotification, object: self, userInfo: userInfo)
            })
        }
    }
}
