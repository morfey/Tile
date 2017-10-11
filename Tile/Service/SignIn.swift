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

class SignIn {
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
}
