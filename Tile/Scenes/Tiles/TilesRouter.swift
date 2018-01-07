//
//  TilesRouter.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

@objc protocol TilesRoutingLogic
{
    func routeToEditTile(segue: UIStoryboardSegue?)
}

protocol TilesDataPassing
{
    var dataStore: TilesDataStore? { get }
}

class TilesRouter: NSObject, TilesRoutingLogic, TilesDataPassing
{
    weak var viewController: TilesViewController?
    var dataStore: TilesDataStore?
    
    // MARK: Routing
    
    func routeToEditTile(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! EditTileViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToEditTile(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "EditTileViewController") as! EditTileViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToEditTile(source: dataStore!, destination: &destinationDS)
            navigateToEditTile(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToEditTile(source: TilesViewController, destination: EditTileViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToEditTile(source: TilesDataStore, destination: inout EditTileDataStore) {
        destination.tile = source.selectedTile
    }
}
