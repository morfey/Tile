//
//  ConnectToTileViewController.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import Starscream
import SwiftKeychainWrapper

protocol ConnectToTileDisplayLogic: class
{
    func displayNewTile(viewModel: ConnectToTile.NewTile.ViewModel)
}

class ConnectToTileViewController: UIViewController, ConnectToTileDisplayLogic
{
    var interactor: ConnectToTileBusinessLogic?
    var router: (NSObjectProtocol & ConnectToTileRoutingLogic & ConnectToTileDataPassing)?
    
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
        let interactor = ConnectToTileInteractor()
        let presenter = ConnectToTilePresenter()
        let router = ConnectToTileRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
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
        connectWebSocket()
        nameField.delegate = self
        passField.delegate = self
    }
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var socket: WebSocket!
    
    func connectWebSocket() {
        let gateway = WifiIPManager.sharedInstance.getRouterIpAddressString()
        socket = WebSocket(url: URL(string: "ws://\(gateway):8080/")!)
        socket.delegate = self
        socket.connect()
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if let name = nameField.text, !name.isEmpty, let pass = passField.text, !pass.isEmpty {
            waitView.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let wifi = WifiModel(name: name, pass: pass)
            let sendData = NSKeyedArchiver.archivedData(withRootObject: wifi)
            socket.write(data: sendData)
            //TODO: - replace by received MAC
            let random = Int(arc4random_uniform(6))
            let mac = "0\(random):0\(random):03:04:ab:cd"
            let userId = KeychainWrapper.standard.string(forKey: UID_KEY)
            let request = ConnectToTile.NewTile.Request(id: mac, userId: userId!)
            self.interactor?.addNewTile(request: request)
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func displayNewTile(viewModel: ConnectToTile.NewTile.ViewModel) {
        waitView.isHidden = true
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Success", message: "Tile is succusfully connected. Enter the name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let action = UIAlertAction(title: "OK", style: .default) { act in
            let name = alert.textFields?.first?.text ?? "Untitled"
            FirebaseService.shared.update(tile: viewModel.tile, name: name)
            self.router?.routeToTiles(segue: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ConnectToTileViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        statusLbl.text = "connected: \(socket.currentURL)"
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        statusLbl.text = error?.localizedDescription ?? "disconnect"
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        statusLbl.text = text
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        //TODO: - first need receive tile's MAC address
        let wifiList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [WifiModel]
        wifiList?.forEach {
            textView.text = textView.text + "\($0.name): \($0.pass)\n"
        }
    }
}

extension ConnectToTileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
