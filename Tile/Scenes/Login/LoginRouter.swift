//
//  LoginRouter.swift
//  Tile
//
//  Created by  Tim on 12.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

@objc protocol LoginRoutingLogic
{
    func routeToTiles(segue: UIStoryboardSegue?)
}

protocol LoginDataPassing
{
    var dataStore: LoginDataStore? { get }
}

class LoginRouter: NSObject, LoginRoutingLogic, LoginDataPassing
{
    weak var viewController: LoginViewController?
    var dataStore: LoginDataStore?
    
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
    
    func navigateToTiles(source: LoginViewController, destination: UINavigationController) {
//        let nav = UINavigationController(rootViewController: destination)
//        source.present(destination, animated: true)
        source.show(destination, sender: nil)
    }
    // MARK: Passing data
}
