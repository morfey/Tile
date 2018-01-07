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
import Unbox

private let DATABASE_REF = Database.database().reference()
private let STORAGE_REF = Storage.storage().reference()

enum TileConnection {
    case success,
         notYourTile,
         recconnect
}

class FirebaseService {
    
    static let shared: FirebaseService = {
        return FirebaseService()
    }()
    
    private(set) var REF_USERS = DATABASE_REF.child(USERS_KEY)
    private(set) var REF_TILES = DATABASE_REF.child(TILES_KEY)
    
    // MARK: - Work with Tiles
    
    func getUsersTiles(byId: String, completion: @escaping(Dictionary<String, Any>) -> ()) {
        var tilesData: Dictionary<String, Any> = [:]
        REF_USERS.child(byId).child(TILES_KEY).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                for (index, key) in snapshot.keys.enumerated() {
                    let id = key
                    self.getTile(byId: id) {tileData in
                        tilesData[id] = tileData
                        if index == snapshot.keys.count - 1 {
                            completion(tilesData)
                        }
                    }
                }
            } else {
                completion(tilesData)
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
    
    func addObserveForTile(tile: Tile, completion: @escaping() -> ()) {
        REF_TILES.child(tile.id).child(CURRENTSTATUS_KEY).observe(.value) { snapshot in
            if let snapshot = snapshot.value as? String {
                if snapshot == "online" {
                    completion()
                }
            }
        }
    }
    
    func waiter(id: String, userId: String, completion: @escaping(_ status: TileConnection, _ tile: Tile?) -> ()) {
        REF_TILES.child(id).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                let tile: Tile? = try? unbox(dictionary: snapshot)
                self.update(tile: tile!, owner: userId)
                self.REF_USERS.child(userId).child(TILES_KEY).updateChildValues([id: true])
                completion(.success, tile)
            } else {
                self.waiter(id: id, userId: userId, completion: completion)
            }
        }
    }
    
    func add(tile: Tile, userId: String, completion: @escaping(_ status: TileConnection, _ tile: Tile?) -> ()) {
        REF_TILES.child(tile.id).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                if let owner = snapshot[OWNER_KEY] as? String {
                    if owner == userId {
                        self.checkTileOwner(tileKey: tile.id) { bool in
                            if bool {
                                completion(.recconnect, tile)
                            } else {
                                completion(.notYourTile, nil)
                            }
                        }
                    } else {
                        completion(.notYourTile, nil)
                    }
                }
            } else {
                do {
                    let values: [String: Any] = try wrap(tile)
                    self.REF_TILES.child(tile.id).updateChildValues(values)
                    self.REF_USERS.child(userId).child(TILES_KEY).updateChildValues([tile.id: true])
                    completion(.success, tile)
                } catch {
                    
                }
            }
        }
    }
    
    func checkTileOwner(tileKey: String, completion: @escaping(Bool) -> ()) {
        if let userId = KeychainWrapper.standard.string(forKey: UID_KEY) {
            REF_USERS.child(userId).child(TILES_KEY).observeSingleEvent(of: .value) { snapshot in
                if let snapshot = snapshot.value as? Dictionary<String, Any> {
                    if snapshot[tileKey] != nil {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func update(tile: Tile, withImage imageUrl: String, completion: @escaping () -> ()) {
        REF_TILES.child(tile.id).updateChildValues([IMAGEURL_KEY: imageUrl, NEEDUPDATEIMAGE_KEY: true])
        completion()
    }
    
    func update(tile: Tile, sleepForceStatus: Bool, completion: (() -> ())? = nil) {
        REF_TILES.child(tile.id).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                if let sleepStatus = snapshot[SLEEPING_KEY] as? Bool, sleepStatus != sleepForceStatus {
                    self.REF_TILES.child(tile.id).updateChildValues([SLEEPING_KEY: sleepForceStatus])
                    completion?()
                }
            }
        }
    }
    
    func update(tile: Tile, sleepTime: String, completion: (() -> ())? = nil) {
        REF_TILES.child(tile.id).observeSingleEvent(of: .value) { snapshot in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                if let currentsSleepTime = snapshot[SLEEPTIME_KEY] as? String, currentsSleepTime != sleepTime {
                    self.REF_TILES.child(tile.id).updateChildValues([SLEEPTIME_KEY: sleepTime, NEEDUPDATESLEEPINGTIME_KEY: true])
                    completion?()
                }
            }
        }
    }
    
    func update(tile: Tile, name: String, completion: (() -> ())? = nil) {
        self.REF_TILES.child(tile.id).updateChildValues([NAME_KEY: name])
        completion?()
    }
    
    func update(tile: Tile, owner: String, completion: (() -> ())? = nil) {
        self.REF_TILES.child(tile.id).updateChildValues([OWNER_KEY: owner])
        completion?()
    }
    
    // MARK: - Work with images
    
    func upload(image: UIImage, forTile tile: Tile, completion: @escaping (String) -> ()) {
        if let imgData = UIImageJPEGRepresentation(image, 1.0) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            STORAGE_REF.child(tile.id).child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print ("USER: Unable to upload image")
                } else {
                    print ("USER: Success upload image")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.update(tile: tile, withImage: url) {
                            completion(url)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Work with User
    
    func getCurrentUserData(completion: @escaping(Dictionary<String, Any>) -> ()) {
        if let current = KeychainWrapper.standard.string(forKey: UID_KEY) {
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
    
    func resetPass(withEmail email: String, completion: @escaping (Error?) -> ()){
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
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
                completion(error)
            }
        })
    }
    
    func createUser(withEmail email: String, pass: String, name: String, lastName: String, completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: pass, completion: {(user, error) in
            if error != nil {
                print ("USER: Unable to auth with Firebase using email: \(error.debugDescription)")
                completion(error)
            } else {
                print ("USER: Successfuly auth email with Firebase")
                if let user = user {
                    user.sendEmailVerification(completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    })
                }
            }
        })
    }
    
    func completeSingIn (id: String, userData: Dictionary<String, String>, completion: @escaping () -> ()) {
        REF_USERS.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.hasChild(id){
                print ("Old User Detected")
                self.createDBUser(uid: id, userData: userData)
                KeychainWrapper.standard.set(id, forKey: UID_KEY)
                KeychainWrapper.standard.set(userData["fullName"] ?? "", forKey: "fullName")
                print("USER: Saved to keychain")
                completion()
            } else {
                print ("New User")
                self.createDBUser(uid: id, userData: userData)
                KeychainWrapper.standard.set(id, forKey: UID_KEY)
                KeychainWrapper.standard.set(userData["fullName"] ?? "", forKey: "fullName")
                completion()
            }
        })
    }
    
    func createDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
}
