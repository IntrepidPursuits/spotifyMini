//
//  AnalysisManager.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/12/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid

class AnalysisManager {
    static let sharedManager = AnalysisManager()
    let spotify = Spotify.manager
    var tracks = Set<SPTPartialTrack>()
    var analyses = [Analysis]()

    // MARK: Fetch 1000 Tracks! (test code)

    func doTheThing() {
        self.spotify.fetchAvailableGenreSeeds() { result in
            if let genres = result.value {
                for genre in genres {
                    self.spotify.fetchRecommendedTracks(forGenre: genre, completion: { result in
                        if let tracks = result.value {
                            self.tracks.unionInPlace(tracks)
                            // round 1 final count: 10396 for "126" genres (didnt count this time)
                            // round 2 final count:  9585 for 114 genres
                            // round 3 final count:  8509 for 99 genres
                        }
                    })
                }
            }
        }
    }

    // MARK: Fetch Analysis For IDs

    func fetchAnalysis(forTrackIDs trackIDs:[String], completion: (Result<[TrackAnalysis]>) -> Void) {
        let commaSeparatedIDs = trackIDs.joinWithSeparator(",")
        let urlString = "\(SpotifyAPIBaseURL)audio-features?ids=\(commaSeparatedIDs)"
        if let request = self.spotify.authenticatedSpotifyRequest(forURL: urlString) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
                if error != nil {
                    completion(.Failure(SpotifyError.RequestFailed))
                } else if let data = data {
                    completion(self.createTrackAnalyses(fromData: data))
                }
            })
            task.resume()
        } else {
            self.spotify.renewSession { wasRenewed in
                if wasRenewed {
                    self.fetchAnalysis(forTrackIDs: trackIDs, completion: completion)
                } else {
                    completion(.Failure(SpotifyError.InvalidSession))
                }
            }
        }
    }

    // MARK: JSON Serialization

    func createTrackAnalyses(fromData data: NSData) -> Result<[TrackAnalysis]> {
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
