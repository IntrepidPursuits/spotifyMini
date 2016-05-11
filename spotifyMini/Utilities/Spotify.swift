//
//  Spotify.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/9/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid

class Spotify {
    static let manager = Spotify()

    var session: SPTSession?
    let auth = SPTAuth.defaultInstance()
    let clientID = "7106e0a1f4c94c6e9e3f1b209e11a3fb"
    let callbackURL = NSURL(string: "intrepid-tom-spotify://callback")!
    let player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)

    // MARK: Creation

    init() {
        self.setupAuth()
        self.session = self.sessionFromUserDefaults()
    }

    // MARK: SPTAuth

    func setupAuth() {
        let auth = SPTAuth.defaultInstance()
        auth.clientID = self.clientID
        auth.redirectURL = self.callbackURL
        auth.sessionUserDefaultsKey = SpotifySessionUserDefaultsKey
        auth.requestedScopes = [SPTAuthStreamingScope]
    }

    // MARK: SPTSession

    func sessionFromUserDefaults() -> SPTSession? {
        if let sessionData = NSUserDefaults.standardUserDefaults().objectForKey(SpotifySessionUserDefaultsKey) as? NSData,
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession {
            print("we have a session already! it is... \(session.isValid() ? "VALID" : "INVALID")")
            return session
        }
        return nil
    }

    // MARK: SPTSearch

    func searchForArtists(withQuery query: String, completion: (Result<[SPTPartialArtist]>) -> Void) {
        SPTSearch.performSearchWithQuery(query, queryType: SPTSearchQueryType.QueryTypeArtist, offset: 0, accessToken: nil) { error, listPage in
            if error != nil {
                completion(.Failure(SpotifyError.RequestFailed))
            } else if let listPage = listPage as? SPTListPage,
                let partialArtists = listPage.items as? [SPTPartialArtist] {
                completion(.Success(partialArtists))
            }
        }
    }

    // MARK: SPTPartialArtist / SPTArtist

    func fetchFullArtist(forPartialArtist partialArtist: SPTPartialArtist, completion: (Result<SPTArtist>) -> Void) {
        if let session = self.session where session.isValid() {
            SPTArtist.artistWithURI(partialArtist.uri, session: self.session) { error, artist in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed)) 
                } else if let artist = artist as? SPTArtist {
                    completion(.Success(artist))
                }
            }
        } else {
            completion(.Failure(SpotifyError.InvalidSession))
        }
    }

    // MARK: Top Tracks

    func fetchTopTracks(forArtist artist: SPTArtist, completion: (Result<[SPTTrack]>) -> Void) {
        if let session = self.session where session.isValid() {
            artist.requestTopTracksForTerritory("US", withSession: session) { error, tracks in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed))
                } else if let tracks = tracks as? [SPTTrack] {
                    completion(.Success(tracks))
                }
            }
        } else {
            completion(.Failure(SpotifyError.InvalidSession))
        }
    }

    // MARK: Playback

    func play(track: SPTTrack, errorCallback: (SpotifyError) -> Void) {
        if let session = self.session where session.isValid() {
            if self.player.loggedIn {
                self.player.playURIs([track.uri], fromIndex: 0) { error in
                    if error != nil {
                        errorCallback(.RequestFailed)
                    }
                }
            } else {
                self.player.loginWithSession(self.session) { error in
                    if error != nil {
                        errorCallback(.RequestFailed)
                    } else {
                        self.play(track, errorCallback: errorCallback)
                    }
                }
            }
        } else {
            errorCallback(.InvalidSession)
        }
    }
    
}