//
//  FirebaseService.swift
//  Tile
//
//  Created by  Tim on 11.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

private let DATABASE_REF = Database.database().reference()
private let STORAGE_REF = Storage.storage().reference()

class FirebaseService {
    
    static let shared: FirebaseService = {
        return FirebaseService()
    }()
    
    private(set) var REF_USERS = DATABASE_REF.child(USERS_KEY)
    
    // MARK: - SignIn/SignOut
    
    func auth(_ credential: AuthCredential){
        Auth.auth().signIn(with: credential, completion: {(user, error) in
            if let error = error {
                print("USER: UNABLE to authentificate with Firebase - \(error)")
            } else {
                print ("USER: Successfully auth with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider, "fullName": user.displayName ?? ""]
                    self.completeSingIn(id: user.uid, userData: userData)
                }
            }
        })      
    }
    
    func auth(email: String, pass: String) {
        Auth.auth().signIn(withEmail: email, password: pass, completion: {(user, error) in
            if error == nil {
                print ("USER: Email user auth with Firebase")
                if let user = user {
                    let userData = ["provider": user.providerID]
                    self.completeSingIn(id: user.uid, userData: userData)
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: pass, completion: {( user,error) in
                    if error != nil {
                        print ("USER: Unable to auth with Firebase using email: \(error.debugDescription)")
                    } else {
                        print ("USER: Successfuly auth email with Firebase")
                        if let user = user {
                            let userData = ["provider": user.providerID]
                            self.completeSingIn(id: user.uid, userData: userData)
                        }
                    }
                })
            }  
        })
    }
    
    func completeSingIn (id: String, userData: Dictionary<String, String>) {
        REF_USERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(id){
                print ("Old User Detected")
                self.createDBUser(uid: id, userData: userData)
                KeychainWrapper.standard.set(id, forKey: "uid")
                KeychainWrapper.standard.set(userData["fullName"] ?? "", forKey: "fullName")
                print("USER: Saved to keychain")
            } else {
                print ("New User")
                self.createDBUser(uid: id, userData: userData)
                KeychainWrapper.standard.set(id, forKey: "uid")
                KeychainWrapper.standard.set(userData["fullName"] ?? "", forKey: "fullName")
            }
        })
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
