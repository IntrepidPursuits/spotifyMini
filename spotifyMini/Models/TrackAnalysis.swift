//
//  TrackAnalysis.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/11/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Genome

struct TrackAnalysis : MappableObject {

    let identifier: String      // matches SPTPartialTrack
    let duration: Double        // in milliseconds by default
    
    let acousticness: Float     // 0.0 - 1.0
    let danceability: Float     // 0.0 - 1.0
    let energy: Float           // 0.0 - 1.0
    let loudness: Float         // overall loudness in dB, "typically -60 <-> 0.0"
    let key: Int                // make an enum ? 0-12, 0 = C, 1 = C#/Db, etc
    
    let tempo: Float            // in BPM
    let valence: Float          // 0.0 - 1.0 "musical positiveness". maybe rename to positivity
    
    let mode: Int
    var isMajor: Bool {
        return mode == 1
    }
    var isMinor: Bool {
        return mode == 0
    }

    // MARK: Questionably Useful
    let instrumentalness: Float
    let speechiness: Float
    let liveness: Float

    // MARK: Creation
    
    init(map: Map) throws {
        self.identifier = try map.extract("id")
        self.duration = try map.extract("duration_ms")

        self.acousticness = try map.extract("acousticness")
        self.danceability = try map.extract("danceability")
        self.energy = try map.extract("energy")
        self.loudness = try map.extract("loudness")
        self.key = try map.extract("key")
        self.mode = try map.extract("mode")
        self.tempo = try map.extract("tempo")
        self.valence = try map.extract("valence")

        self.instrumentalness = try map.extract("instrumentalness")
        self.speechiness = try map.extract("speechiness")
        self.liveness = try map.extract("liveness")
    }
}

extension TrackAnalysis: Equatable { }

func ==(lhs: TrackAnalysis, rhs: TrackAnalysis) -> Bool {
    return lhs.identifier == rhs.identifier
}
