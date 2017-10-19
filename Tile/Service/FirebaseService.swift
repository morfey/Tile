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
    
    func auth(_ credential: AuthCredential, completion: @escaping (Error?) -> ()){
        Auth.auth().signIn(with: credential, completion: {(user, error) in
            if let error = error {
                print("USER: UNABLE to authentificate with Firebase - \(error)")
                completion(error)
            } else {
                print ("USER: Successfully auth with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider, "fullName": user.displayName ?? ""]
                    self.completeSingIn(id: user.uid, userData: userData) {
                        completion(nil)
                    }
                }
            }
        })      
    }
    
    func auth(email: String, pass: String, completion: @escaping (Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: pass, completion: {(user, error) in
            if error == nil {
                print ("USER: Email user auth with Firebase")
                if let user = user {
                    let userData = ["provider": user.providerID]
                    self.completeSingIn(id: user.uid, userData: userData) {
                        completion(nil)
                    }
                }
            } else {
                Auth.auth().createUser(withEmail: email, password: pass, completion: {(user, error) in
                    if error != nil {
                        print ("USER: Unable to auth with Firebase using email: \(error.debugDescription)")
                        completion(error)
                    } else {
                        print ("USER: Successfuly auth email with Firebase")
                        if let user = user {
                            let userData = ["provider": user.providerID]
                            self.completeSingIn(id: user.uid, userData: userData) {
                                completion(nil)
                            }
                        }
                    }
                })
            }  
        })
    }
    
    func completeSingIn (id: String, userData: Dictionary<String, String>, completion: @escaping () -> ()) {
        REF_USERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(id){
                print ("Old User Detected")
                self.createDBUser(uid: id, userData: userData)
                KeychainWrapper.standard.set(id, forKey: "uid")
                KeychainWrapper.standard.set(userData["fullName"] ?? "", forKey: "fullName")
                print("USER: Saved to keychain")
                completion()
            } else {
                print ("New User")
                self.createDBUser(uid: id, userData: userData)
                KeychainWrapper.standard.set(id, forKey: "uid")
                KeychainWrapper.standard.set(userData["fullName"] ?? "", forKey: "fullName")
                completion()
            }
        })
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
