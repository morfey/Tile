//
//  CreateNewAccountModels.swift
//  Tile
//
//  Created by  Tim on 16.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

enum CreateNewAccount {
    enum Error {
        struct Request {
            
        }
        struct Response {
            var error: Error
        }
        struct ViewModel {
            var alert: UIAlertController
        }
    }
    
    enum New {
        struct Request {
            var name: String
            var lastName: String
            var email: String
            var pass: String
        }
        struct Response {
            var error: Error
        }
        struct ViewModel {
            var alert: UIAlertController
        }
    }
}

