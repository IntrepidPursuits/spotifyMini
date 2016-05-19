//
//  Analysis.swift
//  spotifyMini
//
//  Created by Tom OMalley on 5/12/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import RealmSwift

let AnalysisFetchedTrackInfoNotification = "AnalysisFetchedTrackInfoNotification"
let AnalysisNotificationErrorUserInfoKey = "AnalysisUserInfoError"

class Analysis {
    private let spotify = Spotify.manager
    private let tracks: [SPTPartialTrack]
    private var trackAnalysesCache = [String : TrackAnalysis]()
    static let keyTitles = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    // MARK: Public Properties

    let name: String

    var keyValues: [Int] {
        return self.trackAnalysesCache.values.map { $0.key }
    }

    var averageValenceByKey: [Float] {
        let analyses = self.trackAnalysesCache.values
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
        return self.trackAnalysesCache.values.map { $0.energy }.sort { $0 < $1 }
    }

    // MARK: Creation

    init(tracks: [SPTPartialTrack], name: String) {
        self.name = name
        self.tracks = tracks
    }

    // MARK: Fetching

    func fetchAnalyses() {
        let realm = try! Realm()
        var ids = self.tracks.map { $0.identifier } as [String]
        let cachedObjects = realm.objects(TrackAnalysis)
        cachedObjects.forEach { self.trackAnalysesCache[$0.identifier] = $0 }
        ids = ids.filter { !self.trackAnalysesCache.keys.contains($0) }
        print("cached: \(cachedObjects.count), fetching: \(ids.count)")
        if ids.count > 0 {
            self.spotify.fetchAnalysis(forTrackIDs: ids) { result in
                if let analyses = result.value {
                    analyses.forEach { self.trackAnalysesCache[$0.identifier] = $0 }
                    try! realm.write {
                        realm.add(analyses)
                    }
                }
                NSNotificationCenter.defaultCenter().postNotification(AnalysisFetchedTrackInfoNotification, object: self, optionalError: result.error)
            }
        }

        if cachedObjects.count > 0 {
            NSNotificationCenter.defaultCenter().postNotification(AnalysisFetchedTrackInfoNotification, object: self)
        }
    }

    // MARK: Helpers

    private func realmPredicateFormattedString(forIds ids: [String]) -> String {
        let singleQuoteWrappedIds = ids.map { "'\($0)'" }
        let idsString = singleQuoteWrappedIds.joinWithSeparator(",")
        return "{ \(idsString) }"
    }
}
