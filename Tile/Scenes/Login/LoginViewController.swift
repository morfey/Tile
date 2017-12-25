//
//  LoginViewController.swift
//  Tile
//
//  Created by  Tim on 12.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit
import GoogleSignIn

protocol LoginDisplayLogic: class
{
    func displayError(viewModel: Login.Error.ViewModel)
}

class LoginViewController: UIViewController, LoginDisplayLogic, GIDSignInUIDelegate, GoogleManagerDelegate
{
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?
    var presenter: LoginPresentationLogic?
    
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
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        viewController.interactor = interactor
        viewController.router = router
        viewController.presenter = presenter
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
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = SignIn.shared
        SignIn.shared.delegate = self
    }
    
    // MARK: Do something
    
    @IBAction func facebookSignInTapped(_ sender: Any) {
        interactor?.facebookSignIn() {
            self.router?.routeToTiles(segue: nil)
        }
    }
    
    @IBAction func googleSignInTapped(_ sender: Any) {
        interactor?.googleSignIn()
    }
    
    @IBAction func emailSignInTapped(_ sender: Any) {
//        guard let email = emailTextField.text, let pass = passwordTextField.text else { return }
//        interactor?.emailSignIn(email: email, pass: pass) {
//            self.router?.routeToTiles(segue: nil)
//        }
    }
    
    func displayError(viewModel: Login.Error.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func handleError(_ error: Error) {
        presenter?.presentError(error)
    }
    
    func handleSuccess() {
        router?.routeToTiles(segue: nil)
    }
}
