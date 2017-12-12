//
//  CreateNewAccountRouter.swift
//  Tile
//
//  Created by  Tim on 16.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

@objc protocol CreateNewAccountRoutingLogic
{
  func routeToTiles(segue: UIStoryboardSegue?)
}

protocol CreateNewAccountDataPassing
{
  var dataStore: CreateNewAccountDataStore? { get }
}

class CreateNewAccountRouter: NSObject, CreateNewAccountRoutingLogic, CreateNewAccountDataPassing
{
  weak var viewController: CreateNewAccountViewController?
  var dataStore: CreateNewAccountDataStore?
  
  // MARK: Routing
  
    func routeToTiles(segue: UIStoryboardSegue?)
    {
        if let segue = segue {
            let _ = segue.destination as! TilesViewController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "mainNavigation") as! UINavigationController
            navigateToTiles(source: viewController!, destination: destinationVC)
        }
    }

  // MARK: Navigation
  
    func navigateToTiles(source: CreateNewAccountViewController, destination: UINavigationController) {
        source.show(destination, sender: nil)
    }
}
