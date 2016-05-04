//
//  ViewController.swift
//
//
//  Created by Tom O'Malley on 5/4/16.
//
//

import UIKit

class ViewController: UIViewController, SPTAuthViewDelegate {

    var session: SPTSession?

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(recieveSpotifyLogInNotification(_:)), name: AppReturnedFromSpotifyNotification, object: nil)
        self.checkForExistingSession()
    }

    // MARK: SPTSession

    func checkForExistingSession() {
        if let sessionData = NSUserDefaults.standardUserDefaults().objectForKey(SpotifySessionUserDefaultsKey) as? NSData,
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession {
            print("we have a session already! it is... \(session.isValid() ? "VALID" : "INVALID")")
            self.session = session
        }
    }

    // MARK: Actions

    @IBAction func logInTapped(sender: AnyObject) {
        let spotifyLogInVC = SPTAuthViewController.authenticationViewController()
        spotifyLogInVC.delegate = self
        spotifyLogInVC.modalPresentationStyle = .OverCurrentContext
        spotifyLogInVC.modalTransitionStyle = .CrossDissolve
        self.presentViewController(spotifyLogInVC, animated: false, completion: nil)
    }

    // MARK: Notification Handling

    func recieveSpotifyLogInNotification(notification:NSNotification) {
        self.dismissViewControllerAnimated(false, completion: nil)
        if let session = notification.userInfo?["session"] as? SPTSession {
            self.session = session; print("session recieved")
        } else if let error = notification.userInfo?["error"] as? NSError {
            print(error) // FIXME: handle this error
        }
    }


    // MARK: SPTAuthViewDelegate

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        // TODO: make this an application error, handle it
    }

    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        // this method is required, but i have no use for it ...
    }

    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("login success, session: \(session)")
        self.session = session
    }
}
