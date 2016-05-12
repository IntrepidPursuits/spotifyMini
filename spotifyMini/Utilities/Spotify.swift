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

let SpotifyAPIBaseURL = "https://api.spotify.com/v1/"

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
            self.renewSession{ _ in }
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
                    self.session = session
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

    // MARK: SPTPlaylist

    // TODO: remove this? not sure if im gonna use it, so...
    func fetchFeaturedPlaylists(completion: (Result<[SPTPlaylistSnapshot]>) -> Void) {
        if let session = self.session where session.isValid() {
            SPTBrowse.requestFeaturedPlaylistsForCountry("US", limit: 20, offset: 0, locale: nil, timestamp: nil, accessToken: session.accessToken) { error, responseObject in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed))
                } else if let listPage = responseObject as? SPTFeaturedPlaylistList,
                    let items = listPage.items as? [SPTPartialPlaylist] {

                    let playlistURIs = items.map { $0.uri }
                    SPTPlaylistSnapshot.playlistsWithURIs(playlistURIs, session: session) { error, responseObject in
                        if let playlists = responseObject as? [SPTPlaylistSnapshot] {
                            completion(.Success(playlists))
                        } else {
                            completion(.Failure(SpotifyError.RequestFailed))
                        }
                    }

                }
            }
        } else {
            self.renewSession() { wasRenewed in
                if wasRenewed {
                    self.fetchFeaturedPlaylists(completion)
                } else {
                    completion(.Failure(SpotifyError.InvalidSession))
                }
            }
        }
    }

    // MARK: Fetch Recommended Tracks By Genre

    func fetchRecommendedTracks(forGenre genre:String, completion: (Result<[SPTPartialTrack]>) -> Void) {
        let urlString = "\(SpotifyAPIBaseURL)recommendations?limit=100&market=US&seed_genres=\(genre)"
        if let request = self.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed))
                } else if let data = data {
                    completion(self.extractTracks(fromData: data))
                }
            })
            task.resume()
        }
    }

    // TODO: determine if we will actually use this.. if so refactor this and fetchRecommendedTracksForGenre for less repitition
    func fetchRecommendedTracks(withUpToFiveGenres genres:[String], completion: (Result<[SPTPartialTrack]>) -> Void) {
        if genres.count == 0 || genres.count > 5 {
            return // ??? unsure of what else to do with this
        }
        let seedParam = genres.joinWithSeparator(",")
        let urlString = "\(SpotifyAPIBaseURL)recommendations?limit=100&market=US&seed_genres=\(seedParam)"
        if let request = self.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed))
                } else if let data = data {
                    completion(self.extractTracks(fromData: data))
                }
            })
            task.resume()
        }
    }

    // MARK: Fetch Genre Seeds

    func fetchAvailableGenreSeeds(completion: (Result<[String]>) -> Void) {
        let urlString = "\(SpotifyAPIBaseURL)recommendations/available-genre-seeds"
        if let request = self.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed))
                } else if let data = data {
                    do {
                        if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject],
                            let genres = json["genres"] as? [String] {
                            completion(.Success(genres))
                        } else {
                            completion(.Failure(SpotifyError.RequestFailed))
                        }
                    } catch {
                        completion(.Failure(SpotifyError.RequestFailed))
                    }
                }
            })
            task.resume()
        } else {
            self.renewSession { wasRenewed in
                if wasRenewed {
                    self.fetchAvailableGenreSeeds(completion)
                } else {
                    completion(.Failure(SpotifyError.InvalidSession))
                }
            }
        }
    }

    // MARK: Request Helpers

    func authenticatedSpotifyRequest(forURL urlString: String) -> NSMutableURLRequest? {
        if let session = self.session where session.isValid(),
            let token = session.accessToken,
            let url = NSURL(string: urlString) {
            let authorizationHeaderValue = "Bearer \(token)"
            let mutableRequest = NSMutableURLRequest(URL: url)
            mutableRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            return mutableRequest
        }
        return nil
    }

    func extractTracks(fromData data: NSData) -> Result<[SPTPartialTrack]> {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject],
                let rawTracks = json["tracks"] as? [[String:AnyObject]] {
                var tracks = [SPTPartialTrack]()
                for rawTrack in rawTracks {
                    let track = try SPTPartialTrack(decodedJSONObject: rawTrack)
                    tracks.append(track)
                }
                return .Success(tracks)
            } else {
                return .Failure(SpotifyError.RequestFailed)
            }
        } catch {
            return .Failure(SpotifyError.RequestFailed)
        }
    }
}
