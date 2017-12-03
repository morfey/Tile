//
//  ProfileModels.swift
//  Tile
//
//  Created by  Tim on 07.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

enum Profile
{
    // MARK: Use cases
    
    enum User
    {
        struct Request
        {
        }
        struct Response
        {
            var userData: Dictionary<String, Any>
        }
        struct ViewModel
        {
            var email: String
            var fullName: String
            var profileImgUrl: String
        }
    }
}
