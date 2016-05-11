//
//  Spotify.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/9/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid
import Genome

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
        if let session = self.session where !session.isValid() {
            self.renewSession{ _ in
                let testIDs = ["4JpKVNYnVcJ8tuMKjAj50A","2NRANZE9UCmPAS5XVbXL40","24JygzOLM0EmRQeGtFcIcG"]
                let analysisManager = AnalysisManager.sharedManager
                analysisManager.fetchAnalysis(forTrackIDs: testIDs) { result in
                    // FIXME: remove this before you PR, purely for testing
                }
            }
        }
    }

    // MARK: SPTAuth

    func setupAuth() {
        let auth = SPTAuth.defaultInstance()
        auth.clientID = self.clientID
        auth.redirectURL = self.callbackURL
        auth.tokenRefreshURL = NSURL(string: "https://salty-temple-97111.herokuapp.com/refresh")
        auth.tokenSwapURL = NSURL(string: "https://salty-temple-97111.herokuapp.com/swap")
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

    func renewSession(completion: (wasRenewed: Bool) -> Void) {
        if let session = self.session where !session.isValid() {
            self.auth.renewSession(session, callback: { error, session in
                if error != nil {
                    completion(wasRenewed: false)
                } else if let session = session {
                    self.session = session; print("Session has been refreshed")
                    completion(wasRenewed: true)
                }
            })
        } else {
            if let session = self.session where session.isValid() {
                completion(wasRenewed: true)
            } else {
                completion(wasRenewed: false)
            }
        }
    }

    // MARK: SPTSearch

    func searchForArtists(withQuery query: String, completion: (Result<[Artist]>) -> Void) {
        SPTSearch.performSearchWithQuery(query, queryType: SPTSearchQueryType.QueryTypeArtist, offset: 0, accessToken: nil) { error, listPage in
            if error != nil {
                completion(.Failure(SpotifyError.RequestFailed))
            } else if let listPage = listPage as? SPTListPage,
                let partialArtists = listPage.items as? [SPTPartialArtist] {
                let artists = partialArtists.map { Artist(partialArtist: $0) }
                completion(.Success(artists))
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
            self.renewSession() { wasRenewed in
                if wasRenewed {
                    self.fetchFullArtist(forPartialArtist: partialArtist, completion: completion)
                } else {
                    completion(.Failure(SpotifyError.InvalidSession))
                }
            }
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
            self.renewSession() { wasRenewed in
                if wasRenewed {
                    self.fetchTopTracks(forArtist: artist, completion: completion)
                } else {
                    completion(.Failure(SpotifyError.InvalidSession))
                }
            }
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
            self.renewSession() { wasRenewed in
                if wasRenewed {
                    self.play(track, errorCallback: errorCallback)
                } else {
                    errorCallback(.InvalidSession)
                }
            }
        }
    }
}
