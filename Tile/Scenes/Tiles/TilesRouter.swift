//
//  TilesRouter.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol TilesRoutingLogic
{
    func routeToEditImage(segue: UIStoryboardSegue?)
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
    
    func routeToEditImage(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! EditImageViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToEditImage(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "EditImageViewController") as! EditImageViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToEditImage(source: dataStore!, destination: &destinationDS)
            navigateToEditImage(source: viewController!, destination: destinationVC)
        }
    }
    
    // MARK: Navigation
    
    func navigateToEditImage(source: TilesViewController, destination: EditImageViewController) {
        source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToEditImage(source: TilesDataStore, destination: inout EditImageDataStore) {
        destination.originalImage = source.selectedImage
    }
}
