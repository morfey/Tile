//
//  LoginInteractor.swift
//  Tile
//
//  Created by  Tim on 12.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol LoginBusinessLogic
{
    func facebookSignIn(completion: @escaping () -> ())
    func googleSignIn()
    func emailSignIn(email: String, pass: String, completion: @escaping () -> ())
}

protocol LoginDataStore
{
    //var name: String { get set }
}

class LoginInteractor: LoginBusinessLogic, LoginDataStore
{
    var presenter: LoginPresentationLogic?
    var worker: LoginWorker?
    
    // MARK: Do something
    
    func facebookSignIn(completion: @escaping () -> ()) {
        SignIn.shared.facebookSignIn() { error in
            if let error = error {
                self.presenter?.presentError(error)
            } else {
                completion()
            }
        }
    }
    
    func googleSignIn() {
        SignIn.shared.googleSignIn()
    }
    
    func emailSignIn(email: String, pass: String, completion: @escaping () -> ()) {
        SignIn.shared.emailSignIn(email: email, pass: pass) { error in
            if let error = error {
                self.presenter?.presentError(error)
            } else {
                completion()
            }
        }
    }
}
