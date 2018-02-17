//
//  SignInViewController.swift
//  Tile
//
//  Created by  Tim on 24.12.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate, GoogleManagerDelegate
{
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SignIn.shared.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = SignIn.shared
        addGestureRecorgonizerForDismissPicker()
    }
    
    // MARK: Do something
    @IBOutlet weak var emailTextField: DesignableUITextField!
    @IBOutlet weak var passTextField: DesignableUITextField!
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let pass = passTextField.text else { return }
        SignIn.shared.emailSignIn(email: email, pass: pass) { [weak self] error in
            if let error = error {
                self?.presentError(error)
            } else {
                self?.routeToTiles(segue: nil)
            }
        }
    }
    
    @IBAction func facebookBtnTapped(_ sender: UIButton) {
        SignIn.shared.facebookSignIn { [weak self] error in
            if let error = error {
                self?.presentError(error)
            } else {
                self?.routeToTiles(segue: nil)
            }
        }
    }
    
    @IBAction func googleBtnTapped(_ sender: UIButton) {
        SignIn.shared.googleSignIn()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset password", message: "Enter your email", preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8901960784, green: 0.7254901961, blue: 0.4196078431, alpha: 1)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.keyboardAppearance = .dark
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "OK", style: .default) { act in
            let email = alert.textFields?.first?.text ?? "Untitled"
            FirebaseService.shared.resetPass(withEmail: email, completion: { [weak self] error in
                if let error = error {
                    self?.presentError(error)
                } else {
                    
                }
            })
        }
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func handleError(_ error: Error) {
        if (error as NSError).code != -5 {
            presentError(error)
        }
    }
    
    func handleSuccess() {
        routeToTiles(segue: nil)
    }
    
    func presentError(_ error: Error) {
        let alert = UIAlertController(title: "Error in login", message: error.localizedDescription, preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func routeToTiles(segue: UIStoryboardSegue?)
    {
        if let segue = segue {
            let _ = segue.destination as! TilesViewController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "mainNavigation") as! UINavigationController
            show(destinationVC, sender: nil)
        }
    }
}
