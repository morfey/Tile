//
//  GoToSettingsRouter.swift
//  Tile
//
//  Created by  Tim on 19.12.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.
//

import UIKit

@objc protocol GoToSettingsRoutingLogic
{
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol GoToSettingsDataPassing
{
    var dataStore: GoToSettingsDataStore? { get }
}

class GoToSettingsRouter: NSObject, GoToSettingsRoutingLogic, GoToSettingsDataPassing
{
    weak var viewController: GoToSettingsViewController?
    var dataStore: GoToSettingsDataStore?
    
    // MARK: Routing
    
    //func routeToSomewhere(segue: UIStoryboardSegue?)
    //{
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}
    
    // MARK: Navigation
    
    //func navigateToSomewhere(source: GoToSettingsViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}
    
    // MARK: Passing data
    
    //func passDataToSomewhere(source: GoToSettingsDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}
