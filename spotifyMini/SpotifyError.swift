//
//  SpotifyError.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/10/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

enum SpotifyError : ErrorType {
    case LogInFailed
    case InvalidSession
    case RequestFailed
}

extension UIViewController {
    func presentErrorAlert(error: SpotifyError) {
        let message: String
        if error == .LogInFailed {
            message = "Log in with Spotify failed.\nPlease try again."
        } else if error == .InvalidSession {
            message = "Session is invalid.\nLog in to Spotify and try again."
        } else {
            message = "Request failed :("
        }
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
