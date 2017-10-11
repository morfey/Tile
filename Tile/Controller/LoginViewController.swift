//
//  LoginViewController.swift
//  Tile
//
//  Created by  Tim on 11.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = SignIn.shared
    }
    
    // MARK: - SingInButtonActions
    
    @IBAction func facebookSignInTaped(_ sender: Any) {
        SignIn.shared.facebookSignIn()
    }
    @IBAction func googleSignInTapped(_ sender: Any) {
        SignIn.shared.googleSignIn()
    }
    @IBAction func emailSignInTapped(_ sender: Any) {
        guard let email = emailTextFiled.text, let pass = passwordTextField.text else {
            return
        }
        SignIn.shared.emailSignIn(email: email, pass: pass)
    }
}
