//
//  SpotifyError.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/10/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation

let SpotifyMiniErrorDomain = "com.tomalley.spotifyMini"
let SpotifyMiniErrorLogInFailedCode = 123
let SpotifyMiniErrorInvalidSessionCode = 666
let SpotifyMiniErrorRequestFailed = 420

enum SpotifyError : ErrorType {
    case LogInFailed
    case InvalidSession
    case RequestFailed

    init?(error: NSError) {
        if error.domain == SpotifyMiniErrorDomain {
            if error.code == SpotifyMiniErrorLogInFailedCode {
                self = .LogInFailed; return
            } else if error.code == SpotifyMiniErrorInvalidSessionCode {
                self = .InvalidSession; return
            } else if error.code == SpotifyMiniErrorRequestFailed {
                self = .RequestFailed; return
            }
        }
        return nil
    }
}

extension NSError {
    convenience init(spotifyError: SpotifyError) {
        let description: String
        let code: Int
        if spotifyError == .LogInFailed {
            description = "Log in with Spotify failed.\nPlease try again."
            code = SpotifyMiniErrorLogInFailedCode
        } else if spotifyError == .InvalidSession {
            description = "Session is invalid.\nLog in to Spotify and try again."
            code = SpotifyMiniErrorInvalidSessionCode
        } else {
            description = "Request failed :("
            code = SpotifyMiniErrorRequestFailed
        }
        self.init(domain: SpotifyMiniErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey:description])
    }
}

extension UIViewController {
    func presentErrorAlert(error: SpotifyError) {
        let message = NSError(spotifyError: error).localizedDescription
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension NSNotificationCenter {
    func postNotification(name: String, object: AnyObject?, optionalError: ErrorType? = nil) {
        var userInfo: [String:AnyObject]?
        if let error = optionalError as? SpotifyError {
            userInfo = [AnalysisNotificationErrorUserInfoKey : NSError(spotifyError: error)]
        }
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: object, userInfo: userInfo)
    }
}
