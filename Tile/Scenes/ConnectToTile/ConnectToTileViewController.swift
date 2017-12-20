//
//  ConnectToTileViewController.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.


import UIKit
import Starscream
import SwiftKeychainWrapper
import Unbox

protocol ConnectToTileDisplayLogic: class
{
    func displayNewTile(viewModel: ConnectToTile.NewTile.ViewModel)
    func displayWifiConnectionAlert(viewModel: ConnectToTile.ConnectionStatus.ViewModel)
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "network")
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var socket: WebSocket!
    private var mac: String = ""
    private var gateway: String = ""
    var buf: InputStream!
    fileprivate var networks: [WifiModel] = []
    
    func connectWebSocket() {
        gateway = WifiIPManager.sharedInstance.getRouterIpAddressString()
        mac = WifiIPManager.sharedInstance.getRouterMacAddressString()
        socket = WebSocket(url: URL(string: "ws://\(gateway):8080/")!)
        socket.delegate = self
        socket.connect()
    }
    
//    @IBAction func sendBtnTapped(_ sender: Any) {
//        if let name = nameField.text, !name.isEmpty, let pass = passField.text, !pass.isEmpty, socket.isConnected {
//            waitView.isHidden = false
//            activityIndicator.isHidden = false
//            activityIndicator.startAnimating()
//            let wifi = WifiModel(name: name, pass: pass)
//            socket.write(data: wifi.jsonRepresentation)
//
//            let userId = KeychainWrapper.standard.string(forKey: UID_KEY)
//            let request = ConnectToTile.NewTile.Request(id: mac, userId: userId!)
//            self.interactor?.addNewTile(request: request)
//        } else {
//            let alert = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
//            alert.addTextField(configurationHandler: nil)
//            let action = UIAlertAction(title: "OK", style: .default)
//            alert.addAction(action)
//            present(alert, animated: true, completion: nil)
//        }
//    }
    
    func displayNewTile(viewModel: ConnectToTile.NewTile.ViewModel) {
        waitView.isHidden = true
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Success", message: "Tile is succusfully connected. Enter the name", preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        alert.addTextField(configurationHandler: nil)
        let action = UIAlertAction(title: "OK", style: .default) { act in
            let name = alert.textFields?.first?.text ?? "Untitled"
            FirebaseService.shared.update(tile: viewModel.tile, name: name)
            self.router?.routeToTiles(segue: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func displayWifiConnectionAlert(viewModel: ConnectToTile.ConnectionStatus.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func display(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

extension ConnectToTileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "network") {
            cell.textLabel?.text = networks[indexPath.row].name
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Connect", message: "Enter Wi-Fi password", preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        alert.addTextField(configurationHandler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "OK", style: .default) { act in
            self.waitView.isHidden = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            let pass = alert.textFields?.first?.text ?? "Untitled"
            self.networks[indexPath.row].add(pass: pass)
//            self.socket.write(data: self.networks[indexPath.row].jsonRepresentation)
            self.socket.write(string: String.init(data: self.networks[indexPath.row].jsonRepresentation, encoding: .utf8)!)
            
            let userId = KeychainWrapper.standard.string(forKey: UID_KEY)
            let request = ConnectToTile.NewTile.Request(id: self.mac, userId: userId!)
//            self.interactor?.addNewTile(request: request)
        }
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

extension ConnectToTileViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8) {
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
            var reviewArrays: Array<WifiModel> = []
            mac = json["macAddr"] as! String
            for array in json["wifiList"] as! Array<Dictionary<String, Any>> {
                let unbox = Unboxer.init(dictionary: array)
                
                let product = try! WifiModel.init(unboxer: unbox)
                reviewArrays.append(product)
            }
            networks = reviewArrays.removeDuplicates()
            tableView.reloadData()
        }
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
//            if var wifi = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
//
//            }
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

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}
