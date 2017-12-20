//
//  TilesViewController.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit
import SwiftKeychainWrapper

protocol TilesDisplayLogic: class
{
    func displayWifiConnectionAlert(viewModel: Tiles.ConnectionStatus.ViewModel)
    func displayNewTile(viewModel: Tiles.NewTile.ViewModel)
    func displayUsersTiles(viewModel: Tiles.GetTiles.ViewModel)
    func display(alert: UIAlertController)
}

class TilesViewController: UIViewController, TilesDisplayLogic, UINavigationControllerDelegate
{
    var interactor: TilesBusinessLogic?
    var router: (NSObjectProtocol & TilesRoutingLogic & TilesDataPassing)?
    
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
        let interactor = TilesInteractor()
        let presenter = TilesPresenter()
        let router = TilesRouter()
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
    var imagePicker: UIImagePickerController!
    var imgSelected = false
    var tiles: [Tile] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        tilesView.register(UINib(nibName: "TileCell", bundle: nil), forCellWithReuseIdentifier: "TileCell")
        tilesView.delegate = self
        tilesView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if KeychainWrapper.standard.string(forKey: UID_KEY) == nil {
            performSegue(withIdentifier: "Login", sender: nil)
        } else {
            isConnectedToWifi()
            initializeTiles()
        }
    }
    
    // MARK: Do something
    @IBOutlet weak var tilesView: UICollectionView!
    
    @IBAction func selectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func profileBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "Profile", sender: nil)
    }
    
    func isConnectedToWifi() {
        interactor?.checkWifiConnection()
    }
    
    func initializeTiles() {
        let userId = KeychainWrapper.standard.string(forKey: UID_KEY)
        let request = Tiles.GetTiles.Request(userId: userId!)
        interactor?.getTiles(request: request)
    }
    
    func displayWifiConnectionAlert(viewModel: Tiles.ConnectionStatus.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func displayNewTile(viewModel: Tiles.NewTile.ViewModel) {
        interactor?.selectedTile = viewModel.tile
        tiles.append(viewModel.tile)
        performSegue(withIdentifier: "EditTile", sender: nil)
    }
    
    func displayUsersTiles(viewModel: Tiles.GetTiles.ViewModel) {
        tiles.removeAll()
        tiles.append(contentsOf: viewModel.tiles)
        tiles.reverse()
        tilesView.reloadData()
    }
    
    func display(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

extension TilesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = tilesView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as? TileCell {
            let tile = indexPath.row < tiles.count ? tiles[indexPath.row] : nil
            cell.configureCell(tile: tile)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tiles.endIndex > indexPath.row {
            let tile = tiles[indexPath.row]
            interactor?.selectedTile = tile
            performSegue(withIdentifier: "EditTile", sender: nil)
        } else {
            performSegue(withIdentifier: "GoToSettings", sender: nil)
        }

    }
}
