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
import Wrap

private let DATABASE_REF = Database.database().reference()
private let STORAGE_REF = Storage.storage().reference()

class FirebaseService {
    
    static let shared: FirebaseService = {
        return FirebaseService()
    }()
    
    private(set) var REF_USERS = DATABASE_REF.child(USERS_KEY)
    private(set) var REF_TILES = DATABASE_REF.child(TILES_KEY)
    
    // MARK: - Work with Tiles
    
    func getUsersTiles(byId: String, completion: @escaping(Dictionary<String, Any>) -> ()) {
        var tilesData: Dictionary<String, Any> = [:]
        REF_USERS.child(byId).child("tiles").observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                snapshot.keys.forEach {
                    let id = $0
                    self.getTile(byId: id) {tileData in
                        tilesData[id] = tileData
                        if tilesData.keys.count == snapshot.keys.count {
                            completion(tilesData)
                        }
                    }
                }
            }
        }
    }
    
    func getTile(byId: String, completion: @escaping(Dictionary<String, Any>) -> ()) {
        REF_TILES.child(byId).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                completion(snapshot)
            }
        }
    }
    
    func add(tile: Tile, userId: String, completion: @escaping(_ status: String, _ tile: Tile?) -> ()) {
        REF_TILES.child(tile.id).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                if let owner = snapshot["owner"] as? String {
                    if owner == userId {
                        self.checkTileOwner(tileId: tile.id) { bool in
                            if bool {
                                let tile = Tile(name: snapshot["name"] as! String, id: tile.id)
                                completion("Tile reconnect", tile)
                            } else {
                                completion("Not your Tile", nil)
                            }
                        }
                    } else {
                        completion("Not your Tile", nil)
                    }
                }
            } else {
                do {
                    let values: [String: Any] = try wrap(tile)
                    self.REF_TILES.child(tile.id).updateChildValues(values)
                    self.REF_USERS.child(userId).child("tiles").updateChildValues([tile.id: true])
                    completion("New Tile succesfull added", tile)
                } catch {
                    
                }
            }
        }
    }
    
    func checkTileOwner(tileId: String, completion: @escaping(Bool) -> ()) {
        if let userId = KeychainWrapper.standard.string(forKey: "uid") {
            REF_USERS.child(userId).child(TILES_KEY).observeSingleEvent(of: .value) { snapshot in
                if let snapshot = snapshot.value as? Dictionary<String, Any> {
                    if snapshot[tileId] != nil {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func update(tile id: String, withImage imageUrl: String, completion: @escaping () -> ()) {
        REF_TILES.child(id).updateChildValues(["images": imageUrl])
        completion()
    }
    
    // MARK: - Work with images
    
    func upload(image: UIImage, forTile id: String, completion: @escaping (String) -> ()) {
        if let imgData = UIImageJPEGRepresentation(image, 1.0) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            STORAGE_REF.child(id).child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print ("USER: Unable to upload image")
                } else {
                    print ("USER: Success upload image")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.update(tile: id, withImage: url) {
                            completion(url)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Work with User
    
    func getCurrentUserData(completion: @escaping(Dictionary<String, Any>) -> ()) {
        if let current = KeychainWrapper.standard.string(forKey: "uid") {
            REF_USERS.child(current).observeSingleEvent(of: .value) { snapshot in
                if let snapshot = snapshot.value as? Dictionary<String, Any> {
                    completion(snapshot)
                }
            }
        }
    }
    
    // MARK: - SignIn/SignOut
    
    func signOut(completion: @escaping () -> ()) {
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            
        }
    }
    
    func auth(_ credential: AuthCredential, completion: @escaping (Error?) -> ()){
        Auth.auth().signIn(with: credential, completion: {(user, error) in
            if let error = error {
                print("USER: UNABLE to authentificate with Firebase - \(error)")
                completion(error)
            } else {
                print ("USER: Successfully auth with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider, "fullName": user.displayName ?? "", "email": user.email ?? "", "profileImgUrl": user.photoURL?.absoluteString ?? ""]
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
