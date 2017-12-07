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
    func display(alert: UIAlertController)
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
    private var mac: String = ""
    private var gateway: String = ""
    var buf: InputStream!
    
    func connectWebSocket() {
        gateway = WifiIPManager.sharedInstance.getRouterIpAddressString()
        mac = WifiIPManager.sharedInstance.getRouterMacAddressString()
        socket = WebSocket(url: URL(string: "ws://\(gateway):8080/")!)
        socket.delegate = self
        socket.connect()
    }
    
    @IBAction func sendBtnTapped(_ sender: Any) {
        if let name = nameField.text, !name.isEmpty, let pass = passField.text, !pass.isEmpty, socket.isConnected {
            waitView.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            let wifi = WifiModel(name: name, pass: pass)
            socket.write(data: wifi.jsonRepresentation)
            let userId = KeychainWrapper.standard.string(forKey: UID_KEY)
            let request = ConnectToTile.NewTile.Request(id: mac, userId: userId!)
            self.interactor?.addNewTile(request: request)
        } else {
            let alert = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
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
    
    func display(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)

    }
}

extension ConnectToTileViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        statusLbl.text = "connected: "
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        statusLbl.text = error?.localizedDescription ?? "disconnect"
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        statusLbl.text = text
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        buf = InputStream(data: data)
        buf.open()
        readAvailableBytes(stream: buf)
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = buf.read(buffer, maxLength: 1024)
            
            if numberOfBytesRead < 0 {
                if let _ = buf.streamError {
                    break
                }
            }
            
            if var wifi = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                wifi = Array(Set(wifi))
                wifi.forEach {
                    textView.text.append("\($0.components(separatedBy: .whitespaces).joined())\n")
                }
            }
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> [String]? {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .ascii,
                                       freeWhenDone: true) else {return nil}
        
        return Array(stringArray.components(separatedBy: "\0").dropFirst(11))
    }
}

extension ConnectToTileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
