//
//  TrackAnalysis.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/11/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Genome

// TODO: use Genome or some other JSON mapper for this
struct TrackAnalysis : MappableObject {

    // MARK: Meta
    let id: String // Spotify ID for the track.
    let uri: String // Spotify URI for the track, actually is spotify:track:<id>
    // ^ these are probably better off stored on the track itself 
    let duration: Double // comes in milliseconds by default, decide how you wanna store them

    // MARK: Cool stuff that is definitely in
    let acousticness: Float    // 0.0 - 1.0
    let danceability: Float    // 0.0 - 1.0
    let energy: Float          // 0.0 - 1.0
    let loudness: Float // overall loudness in dB, "typically -60 <-> 0.0"
    let key: Int // make an enum ? 0-12, 0 = C, 1 = C#/Db, etc
    let mode: Int // Store mode directly, use computed getters for readability
    var isMajor: Bool {
        return mode == 1
    }
    var isMinor: Bool {
        return mode == 0
    }
    let tempo: Float // in BPM
    let valence: Float         // 0.0 - 1.0 "musical positiveness". maybe rename to positivity

    // MARK: Questionably Cool
    let instrumentalness: Float
    // "Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content. Values above 0.5 are intended to represent instrumental tracks, but confidence is higher as the value approaches 1.0."

    let speechiness: Float
    // Basically the opposite of instrumentalness. "... Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks."

    let liveness: Float
    // "Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live."

    let timeSignature: Int // isnt a true time signature. "An estimated overall time signature of a track. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure)."

    // dont forget each track has a popularity !

    init(map: Map) throws {
        self.id = try map.extract("id")
        self.uri = try map.extract("uri")
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
        self.timeSignature = try map.extract("time_signature")
    }
}
