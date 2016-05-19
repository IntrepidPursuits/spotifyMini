//
//  Genre.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/19/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import RealmSwift

final class Genre : RealmSwift.Object {
    dynamic var stringValue = ""

    convenience init(string: String) {
        self.init()
        self.stringValue = string
    }
}