//
//  EditTileRouter.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

@objc protocol EditTileRoutingLogic
{
    func routeToTiles(segue: UIStoryboardSegue?)
}

protocol EditTileDataPassing
{
    var dataStore: EditTileDataStore? { get }
}

class EditTileRouter: NSObject, EditTileRoutingLogic, EditTileDataPassing
{
    weak var viewController: EditTileViewController?
    var dataStore: EditTileDataStore?
    
    // MARK: Routing
    
    func routeToTiles(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! TilesViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToTiles(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "TilesViewController") as! TilesViewController
            var destinationDS = destinationVC.router!.dataStore!
//            passDataToTiles(source: dataStore!, destination: &destinationDS)
            navigateToTiles(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToTiles(source: EditTileViewController, destination: TilesViewController)
    {
        source.navigationController?.popViewController(animated: true)
//        source.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Passing data
    
    func passDataToTiles(source: EditTileDataStore, destination: inout TilesDataStore)
    {
//        destination.selectedImage = source.imageWithFilter
    }
}
