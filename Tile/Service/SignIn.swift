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

class SignIn: NSObject, GIDSignInDelegate {
    static let shared: SignIn = {
        return SignIn()
    }()
    
    func facebookSignIn() {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: LoginViewController.self()) { (result, error) in
            if let error = error {
                print("USER: UNABLE to authentificate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print ("USER: User canceled authentification")
            }
            else {
                print ("USER: Successfully auth with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FirebaseService.shared.auth(credential)
            }
        }
    }
    
    func googleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseService.shared.auth(credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().signOut()
    }
}
