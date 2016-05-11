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

    // MARK: Fetch Analysis For IDs

    func fetchAnalysis(forTrackIDs trackIDs:[String], completion: (Result<[TrackAnalysis]>) -> Void) {

        let commaSeparatedIDs = trackIDs.joinWithSeparator(",")
        let urlString = "https://api.spotify.com/v1/audio-features?ids=\(commaSeparatedIDs)"

        if let session = self.spotify.session where session.isValid(),
            let token = session.accessToken,
            let url = NSURL(string: urlString) {

            let authorizationHeaderKey = "Authorization"
            let authorizationHeaderValue = "Bearer \(token)"
            let mutableRequest = NSMutableURLRequest(URL: url)
            mutableRequest.setValue(authorizationHeaderValue, forHTTPHeaderField: authorizationHeaderKey)

            let task = NSURLSession.sharedSession().dataTaskWithRequest(mutableRequest, completionHandler: { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
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
                    print("your session renewal code's the wooooorst")
                    completion(.Failure(SpotifyError.InvalidSession))
                }
            }
        }
    }

    // MARK: Helpers

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

        } catch (let serializationError) {
            print(serializationError)
            return .Failure(SpotifyError.RequestFailed)
        }
    }
}