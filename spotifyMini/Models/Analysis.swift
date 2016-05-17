//
//  Analysis.swift
//  spotifyMini
//
//  Created by Tom OMalley on 5/12/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

let AnalysisFetchedTrackInfoNotification = "AnalysisFetchedTrackInfoNotification"
let AnalysisNotificationErrorUserInfoKey = "AnalysisUserInfoError"

class Analysis {
    private let spotify = Spotify.manager
    private let tracks: [SPTPartialTrack]
    private var trackAnalyses: [TrackAnalysis]?
    static let keyTitles = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    // MARK: Public Properties

    let name: String

    var keyValues: [Int]? {
        if let analyses = self.trackAnalyses {
            return analyses.map { $0.key }
        }
        return nil
    }

    var averageValenceByKey: [Float]? {
        if let analyses = self.trackAnalyses {
            var averageValences = [Float]()
            for i in 0..<Analysis.keyTitles.count {
                let analysesForThisKey = analyses.filter { $0.key == i }
                let valences = analysesForThisKey.map { $0.valence }
                let totalValence = valences.reduce(0, combine:+)
                if valences.count > 0 {
                    let averageValence = totalValence / Float(valences.count)
                    averageValences.append(averageValence)
                } else {
                    averageValences.append(0.0)
                }
            }
            return averageValences
        }
        return nil
    }

    var energyValues: [Float]? {
        if let analyses = self.trackAnalyses {
            return analyses.map { $0.energy }
        }
        return nil
    }

    // MARK: Creation

    init(tracks: [SPTPartialTrack], name: String) {
        self.name = name
        self.tracks = tracks
        self.fetchAnalyses()
    }

    // MARK: Fetching

    func fetchAnalyses() {
        let ids = self.tracks.map { $0.identifier } as [String]
        self.spotify.fetchAnalysis(forTrackIDs: ids) { result in
            self.trackAnalyses = result.value
            var userInfo: [String:AnyObject]?
            if let error = result.error as? SpotifyError {
                userInfo = [AnalysisNotificationErrorUserInfoKey : NSError(spotifyError: error)]
            }
            NSNotificationCenter.defaultCenter().postNotificationName(AnalysisFetchedTrackInfoNotification, object: self, userInfo: userInfo)
        }
    }
}
