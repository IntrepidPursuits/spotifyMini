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
    private var trackAnalyses = [String: TrackAnalysis]()
    static let keyTitles = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    // MARK: Public Properties

    let name: String

    var keyValues: [Int] {
        return self.trackAnalyses.values.map { $0.key }
    }

    var averageValenceByKey: [Float] {
        let analyses = self.trackAnalyses.values
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

    var energyValues: [Float] {
        return self.trackAnalyses.values.map { $0.energy }
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
        // TODO: fetch from local store
        // how to persist each of the properties
        self.spotify.fetchAnalysis(forTrackIDs: ids) { result in
            if let analyses = result.value {
                analyses.forEach { self.trackAnalyses.updateValue($0, forKey: $0.identifier) }
            }
            // TODO: save to local store
            // TODO: notificationCenter extension
            var userInfo: [String:AnyObject]?
            if let error = result.error as? SpotifyError {
                userInfo = [AnalysisNotificationErrorUserInfoKey : NSError(spotifyError: error)]
            }
            NSNotificationCenter.defaultCenter().postNotificationName(AnalysisFetchedTrackInfoNotification, object: self, userInfo: userInfo)
        }
    }
}
