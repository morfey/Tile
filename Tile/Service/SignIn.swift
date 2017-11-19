//
//  SignIn.swift
//  Tile
//
//  Created by  Tim on 11.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import Firebase

protocol GoogleManagerDelegate {
    func handleError(_ error: Error)
    func handleSuccess()
}

class SignIn: NSObject, GIDSignInDelegate {
    static let shared: SignIn = {
        return SignIn()
    }()
    
    var delegate: GoogleManagerDelegate?
    
    // MARK: - Facebook
    
    func facebookSignIn(completion: @escaping (Error?) -> ()) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: LoginViewController.self()) { (result, error) in
            if let error = error {
                print("USER: UNABLE to authentificate with Facebook - \(error)")
                completion(error)
            } else if result?.isCancelled == true {
                print ("USER: User canceled authentification")
            }
            else {
                print ("USER: Successfully auth with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FirebaseService.shared.auth(credential) { error in
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Google+
    
    func googleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard let authentication = user.authentication else {
            delegate?.handleError(error!)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseService.shared.auth(credential) { error in
            if let error = error {
                self.delegate?.handleError(error)
            } else {
                self.delegate?.handleSuccess()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    // MARK: - Email
    
    func emailSignIn(email: String, pass: String, completion: @escaping (Error?) -> ()) {
        FirebaseService.shared.auth(email: email, pass: pass) { error in
            completion(error)
        }
    }
    
    func signOut() {
        FirebaseService.shared.signOut {
            if GIDSignIn.sharedInstance().currentUser != nil {
                GIDSignIn.sharedInstance().signOut()
            }
        }
    }
}
