//
//  TrackAnalysis.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/11/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Genome

final class TrackAnalysis : RealmSwift.Object, MappableObject {

    dynamic var identifier: String = ""       // matches SPTPartialTrack
    dynamic var duration: Double = 0.0        // in milliseconds by default
    
    dynamic var acousticness: Float = 0.0     // 0.0 - 1.0
    dynamic var danceability: Float = 0.0     // 0.0 - 1.0
    dynamic var energy: Float = 0.0           // 0.0 - 1.0
    dynamic var loudness: Float = 0.0         // overall loudness in dB, "typically -60 <-> 0.0"
    dynamic var key: Int = 0                  // make an enum ? 0-12, 0 = C, 1 = C#/Db, etc
    
    dynamic var tempo: Float = 0.0            // in BPM
    dynamic var valence: Float = 0.0          // 0.0 - 1.0 "musical positiveness". maybe rename to positivity
    
    dynamic var mode: Int  = 0
    var isMajor: Bool {
        return mode == 1
    }
    var isMinor: Bool {
        return mode == 0
    }

    // MARK: Questionably Useful
    dynamic var instrumentalness: Float = 0.0
    dynamic var speechiness: Float = 0.0
    dynamic var liveness: Float = 0.0

    // MARK: Creation
    
    convenience init(map: Map) throws {
        self.init()
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

    // MARK: Realm Required Initializers
    
    required init() {
        super.init()
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}

extension TrackAnalysis: Equatable { }

func ==(lhs: TrackAnalysis, rhs: TrackAnalysis) -> Bool {
    return lhs.identifier == rhs.identifier
}
