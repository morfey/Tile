//
//  ConnectToTileInteractor.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import SocketIO

protocol ConnectToTileBusinessLogic
{
    func doSomething(request: ConnectToTile.Something.Request)
}

protocol ConnectToTileDataStore
{
    //var name: String { get set }
}

class ConnectToTileInteractor: ConnectToTileBusinessLogic, ConnectToTileDataStore
{
    var presenter: ConnectToTilePresentationLogic?
    var worker: ConnectToTileWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSomething(request: ConnectToTile.Something.Request)
    {
        worker = ConnectToTileWorker()
        worker?.doSomeWork()
        
        let response = ConnectToTile.Something.Response()
        presenter?.presentSomething(response: response)
    }
}
