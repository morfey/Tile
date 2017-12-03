//
//  CreateNewAccountInteractor.swift
//  Tile
//
//  Created by  Tim on 16.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol CreateNewAccountBusinessLogic
{

}

protocol CreateNewAccountDataStore
{
  //var name: String { get set }
}

class CreateNewAccountInteractor: CreateNewAccountBusinessLogic, CreateNewAccountDataStore
{
  var presenter: CreateNewAccountPresentationLogic?
  var worker: CreateNewAccountWorker?
  //var name: String = ""
  
}
