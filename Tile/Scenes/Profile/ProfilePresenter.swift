//
//  ProfilePresenter.swift
//  Tile
//
//  Created by  Tim on 07.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

protocol ProfilePresentationLogic
{
    func presentUserData(response: Profile.User.Response)
}

class ProfilePresenter: ProfilePresentationLogic
{
    weak var viewController: ProfileDisplayLogic?
    
    func presentUserData(response: Profile.User.Response) {
        let email = response.userData["email"] as! String
        let fullName = response.userData["fullName"] as! String
        let profileImgUrl = response.userData["profileImgUrl"] as! String
        let viewModel = Profile.User.ViewModel(email: email, fullName: fullName, profileImgUrl: profileImgUrl)
        viewController?.displayUserData(viewModel: viewModel)
    }
    
}
