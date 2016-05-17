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

    // MARK: Fetch Recommended Tracks By Genre

    func fetchRecommendedTracks(forGenre genre:String, completion: (Result<[SPTPartialTrack]>) -> Void) {
        let urlString = "\(SpotifyAPIBaseURL)recommendations?limit=100&market=US&seed_genres=\(genre)"
        if let request = self.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                let result: Result<[SPTPartialTrack]>
                if let data = data {
                    result = self.extractTracks(fromData: data)
                } else {
                    result = .Failure(SpotifyError.RequestFailed)
                }
                Qu.Main {
                    completion(result)
                }
            })
            task.resume()
        }  else {
            self.renewSession { wasRenewed in
                if wasRenewed {
                    self.fetchRecommendedTracks(forGenre: genre, completion: completion)
                } else {
                    Qu.Main {
                        completion(.Failure(SpotifyError.InvalidSession))
                    }
                }
            }
        }
    }

    // MARK: Fetch Genre Seeds

    func fetchAvailableGenreSeeds(completion: (Result<[String]>) -> Void) {
        let urlString = "\(SpotifyAPIBaseURL)recommendations/available-genre-seeds"
        if let request = self.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                let result: Result<[String]>
                if let data = data {
                    result = self.extractGenres(fromData: data)
                } else {
                    result = .Failure(SpotifyError.RequestFailed)
                }
                Qu.Main {
                    completion(result)
                }
            })
            task.resume()
        } else {
            self.renewSession { wasRenewed in
                if wasRenewed {
                    self.fetchAvailableGenreSeeds(completion)
                } else {
                    Qu.Main {
                        completion(.Failure(SpotifyError.InvalidSession))
                    }
                }
            }
        }
    }

    // MARK: Fetch Analysis For IDs

    func fetchAnalysis(forTrackIDs trackIDs:[String], completion: (Result<[TrackAnalysis]>) -> Void) {
        let commaSeparatedIDs = trackIDs.joinWithSeparator(",")
        let urlString = "\(SpotifyAPIBaseURL)audio-features?ids=\(commaSeparatedIDs)"
        if let request = self.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                let result: Result<[TrackAnalysis]>
                if let data = data {
                    result = self.createTrackAnalyses(fromData: data)
                } else {
                    result = .Failure(SpotifyError.RequestFailed)
                }
                Qu.Main {
                    completion(result)
                }
            })
            task.resume()
        } else {
            self.renewSession { wasRenewed in
                if wasRenewed {
                    self.fetchAnalysis(forTrackIDs: trackIDs, completion: completion)
                } else {
                    Qu.Main {
                        completion(.Failure(SpotifyError.InvalidSession))
                    }
                }
            }
        }
    }

    // MARK: Request Helpers

    private func authenticatedSpotifyRequest(forURL urlString: String) -> NSMutableURLRequest? {
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

    private func extractTracks(fromData data: NSData) -> Result<[SPTPartialTrack]> {
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

    private func extractGenres(fromData data: NSData) -> Result<[String]> {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject],
                let genres = json["genres"] as? [String] {
                return .Success(genres)
            } else {
                return .Failure(SpotifyError.RequestFailed)
            }
        } catch {
            return .Failure(SpotifyError.RequestFailed)
        }
    }

    private func createTrackAnalyses(fromData data: NSData) -> Result<[TrackAnalysis]> {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject],
                let jsonAnalyses = json["audio_features"] as? [[String:AnyObject]] {
                var analysesObjects = [TrackAnalysis]()
                for jsonAnalysis in jsonAnalyses {
                    let analysis = try TrackAnalysis(js: jsonAnalysis)
                    analysesObjects.append(analysis)
                }
                return .Success(analysesObjects)
            } else {
                return .Failure(SpotifyError.RequestFailed)
            }
        } catch {
            return .Failure(SpotifyError.RequestFailed)
        }
    }
}
