//
//  LoginModels.swift
//  Tile
//
//  Created by  Tim on 12.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

enum Login
{
    // MARK: Use cases
    enum Auth {
        struct Request {
            
        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }
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
}
