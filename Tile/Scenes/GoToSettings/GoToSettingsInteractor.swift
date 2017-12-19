//
//  GoToSettingsInteractor.swift
//  Tile
//
//  Created by  Tim on 19.12.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol GoToSettingsBusinessLogic
{
    func doSomething(request: GoToSettings.Something.Request)
}

protocol GoToSettingsDataStore
{
    //var name: String { get set }
}

class GoToSettingsInteractor: GoToSettingsBusinessLogic, GoToSettingsDataStore
{
    var presenter: GoToSettingsPresentationLogic?
    var worker: GoToSettingsWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSomething(request: GoToSettings.Something.Request)
    {
        worker = GoToSettingsWorker()
        worker?.doSomeWork()
        
        let response = GoToSettings.Something.Response()
        presenter?.presentSomething(response: response)
    }
}
