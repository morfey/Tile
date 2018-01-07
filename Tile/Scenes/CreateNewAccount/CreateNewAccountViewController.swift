//
//  CreateNewAccountViewController.swift
//  Tile
//
//  Created by  Tim on 16.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit

protocol CreateNewAccountDisplayLogic: class
{
    func displayError(viewModel: CreateNewAccount.Error.ViewModel)
}

class CreateNewAccountViewController: UIViewController, CreateNewAccountDisplayLogic
{
    var interactor: CreateNewAccountBusinessLogic?
    var router: (NSObjectProtocol & CreateNewAccountRoutingLogic & CreateNewAccountDataPassing)?
    
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
        let interactor = CreateNewAccountInteractor()
        let presenter = CreateNewAccountPresenter()
        let router = CreateNewAccountRouter()
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
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var acceptBtn: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottom?.constant = 0.0
            } else {
                self.bottom?.constant = -endFrame!.size.height
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    @IBAction func acceptBtnTapped(_ sender: Any) {
        acceptBtn.isSelected = !acceptBtn.isSelected
    }
    
    @IBAction func createAccountBtnTapped(_ sender: Any) {
        guard let name = nameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let pass = passTextField.text else { return }
        let request = CreateNewAccount.New.Request(name: name, lastName: lastName, email: email, pass: pass)
        interactor?.createNewAccount(request: request) { [weak self] in
            let alert = UIAlertController(title: "Verification", message: "We sent you a letter with confirmation code. Please follow by link in email.", preferredStyle: .alert)
            alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self?.router?.routeToTiles(segue: nil)
            })
            alert.addAction(action)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func displayError(viewModel: CreateNewAccount.Error.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
}
