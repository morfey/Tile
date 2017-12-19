//
//  GoToSettingsViewController.swift
//  Tile
//
//  Created by  Tim on 19.12.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.
//

import UIKit

protocol GoToSettingsDisplayLogic: class
{
    func displaySomething(viewModel: GoToSettings.Something.ViewModel)
}

class GoToSettingsViewController: UIViewController, GoToSettingsDisplayLogic
{
    var interactor: GoToSettingsBusinessLogic?
    var router: (NSObjectProtocol & GoToSettingsRoutingLogic & GoToSettingsDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = GoToSettingsInteractor()
        let presenter = GoToSettingsPresenter()
        let router = GoToSettingsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething()
    {
        let request = GoToSettings.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: GoToSettings.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
}
