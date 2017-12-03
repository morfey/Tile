//
//  ProfileInteractor.swift
//  Tile
//
//  Created by  Tim on 07.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol ProfileBusinessLogic
{
    func getUserData()
}

protocol ProfileDataStore
{
  //var name: String { get set }
}

class ProfileInteractor: ProfileBusinessLogic, ProfileDataStore
{
  var presenter: ProfilePresentationLogic?
  var worker: ProfileWorker?
  //var name: String = ""
  
  // MARK: Do something
  
    func getUserData() {
        FirebaseService.shared.getCurrentUserData() { [weak self] data in
            let response = Profile.User.Response(userData: data)
            self?.presenter?.presentUserData(response: response)
        }
    }

}
