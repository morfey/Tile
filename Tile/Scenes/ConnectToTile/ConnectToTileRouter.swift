//
//  ConnectToTileRouter.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

@objc protocol ConnectToTileRoutingLogic
{
    func routeToTiles(segue: UIStoryboardSegue?)
}

protocol ConnectToTileDataPassing
{
    var dataStore: ConnectToTileDataStore? { get }
}

class ConnectToTileRouter: NSObject, ConnectToTileRoutingLogic, ConnectToTileDataPassing
{
    weak var viewController: ConnectToTileViewController?
    var dataStore: ConnectToTileDataStore?
    
    // MARK: Routing
    
    func routeToTiles(segue: UIStoryboardSegue?)
    {
      if let segue = segue {
        let destinationVC = segue.destination as! TilesViewController
        var destinationDS = destinationVC.router!.dataStore!
        passDataToTiles(source: dataStore!, destination: &destinationDS)
      } else {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "TilesViewController") as! TilesViewController
        var destinationDS = destinationVC.router!.dataStore!
        passDataToTiles(source: dataStore!, destination: &destinationDS)
        navigateToTiles(source: viewController!, destination: destinationVC)
      }
    }
    
    // MARK: Navigation
    
    func navigateToTiles(source: ConnectToTileViewController, destination: TilesViewController)
    {
        source.dismiss(animated: true, completion: nil)
        source.navigationController?.popViewController(animated: true)
//      source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToTiles(source: ConnectToTileDataStore, destination: inout TilesDataStore)
    {
        destination.newTile = source.tile
    }
}
