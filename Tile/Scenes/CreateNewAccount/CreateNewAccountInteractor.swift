//
//  CreateNewAccountInteractor.swift
//  Tile
//
//  Created by  Tim on 16.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol CreateNewAccountBusinessLogic
{
    func createNewAccount(request: CreateNewAccount.New.Request, completion: @escaping () -> ())
}

protocol CreateNewAccountDataStore
{

}

class CreateNewAccountInteractor: CreateNewAccountBusinessLogic, CreateNewAccountDataStore
{
    var presenter: CreateNewAccountPresentationLogic?
    var worker: CreateNewAccountWorker?
    //var name: String = ""
    
    func createNewAccount(request: CreateNewAccount.New.Request, completion: @escaping () -> ()) {
        FirebaseService.shared.createUser(withEmail: request.email, pass: request.pass, name: request.name, lastName: request.lastName) { [weak self] error in
            if let error = error {
                self?.presenter?.presentError(error)
            } else {
                completion()
            }
        }
    }
}
