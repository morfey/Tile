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
    func displayEditedTile(viewModel: Tiles.EditedImage.ViewModel)
}

class TilesViewController: UIViewController, TilesDisplayLogic, UINavigationControllerDelegate, UIGestureRecognizerDelegate
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
    var isChecking: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        tilesView.register(UINib(nibName: "TileCell", bundle: nil), forCellWithReuseIdentifier: "TileCell")
        tilesView.delegate = self
        tilesView.dataSource = self
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 1.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.tilesView.addGestureRecognizer(lpgr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isConnectedToWifi()
        initializeTiles()
//        isChecking = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if KeychainWrapper.standard.string(forKey: UID_KEY) == nil {
            performSegue(withIdentifier: "Login", sender: nil)
        }
//        if let tile = interactor?.editedTile {
//            guard let index = tiles.index(where: {$0.id == tile.0.id}), let item = tilesView.cellForItem(at: IndexPath(item: index, section: 0)) as? TileCell else {return}
//            item.tileImageView.contentMode = .scaleAspectFill
//            item.tileImageView.image = tile.1
//        }
    }
    
    // MARK: Do something
    @IBOutlet weak var tilesView: UICollectionView!
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func selectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func profileBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "Profile", sender: nil)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.tilesView)
        
        if let indexPath = self.tilesView.indexPathForItem(at: p) {
            let tile = self.tiles[indexPath.row]
            let user = KeychainWrapper.standard.string(forKey: UID_KEY) ?? ""
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete \(tile.name)", preferredStyle: .alert)
            alert.view.tintColor = #colorLiteral(red: 0.8930782676, green: 0.7270605564, blue: 0.417747438, alpha: 1)
            let action = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.tilesView.performBatchUpdates({
                    self.tiles.remove(at: indexPath.row)
                    self.tilesView.deleteItems(at: [indexPath])
                    FirebaseService.shared.delete(tile: tile, forUser: user)
                }) { (finished) in
                    self.tilesView.reloadItems(at: self.tilesView.indexPathsForVisibleItems)
                }
            })
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isConnectedToWifi() {
        interactor?.checkWifiConnection()
    }
    
    func initializeTiles() {
        if let userId = KeychainWrapper.standard.string(forKey: UID_KEY) {
            waitView.isHidden = false
            activityIndicator.startAnimating()
            let request = Tiles.GetTiles.Request(userId: userId)
            interactor?.getTiles(request: request)
        }
    }
    
    func displayWifiConnectionAlert(viewModel: Tiles.ConnectionStatus.ViewModel) {
        present(viewModel.alert, animated: true, completion: nil)
    }
    
    func displayNewTile(viewModel: Tiles.NewTile.ViewModel) {
        isChecking = false
        interactor?.selectedTile = viewModel.tile
        tiles.append(viewModel.tile)
        performSegue(withIdentifier: "EditTile", sender: nil)
    }
    
    func displayUsersTiles(viewModel: Tiles.GetTiles.ViewModel) {
        
        waitView.isHidden = true
        activityIndicator.stopAnimating()
        viewModel.tiles.forEach {
            FirebaseService.shared.deleteObserve(tile: $0, completion: { [weak self] in
                self?.isChecking = false
                self?.initializeTiles()
            })
            FirebaseService.shared.imageObserve(tile: $0, completion: { [weak self] in
                self?.initializeTiles()
            })
            FirebaseService.shared.sleepingObserver(tile: $0, completion: { [weak self] tile in
                self?.initializeTiles()
            })
            FirebaseService.shared.offlineObserver(tile: $0, completion: { [weak self] tile in
                self?.initializeTiles()
            })
        }
        if !isChecking {
            isChecking = true
            FirebaseService.shared.checkStatus(of: viewModel.tiles) { [weak self] in
                self?.initializeTiles()
            }
        }
        tiles.removeAll()
        tiles.append(contentsOf: viewModel.tiles)
        tiles.reverse()
        tilesView.isHidden = false
        tilesView.reloadData()
    }
    
    func display(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func displayEditedTile(viewModel: Tiles.EditedImage.ViewModel) {
//        if let index = tiles.index(where: {viewModel.tile.id == $0.id}) {
////            tilesView.performBatchUpdates({
//                if let cell = tilesView.cellForItem(at: IndexPath(item: index, section: 0)) as? TileCell {
//                    cell.tileImageView.image = viewModel.image
//                }
////            }, completion: { (finished) in
////                self.tilesView.reloadItems(at: [IndexPath(item: index, section: 0)])
////            })
//        }
    }
}
 
 extension TilesViewController: TileCellDelegate {
    func sleepBtnTapped(for tile: Tile, status: Bool) {
        FirebaseService.shared.update(tile: tile, sleepForceStatus: status)
    }
    
    func showOfflineAlert() {
        let alert = UIAlertController(title: "Tile is offline", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        present(alert, animated: true, completion: nil)
    }
 }

extension TilesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = 140
        let totalSpacingWidth = 10
        if tiles.count == 0 {
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            let topInset = (collectionView.frame.height - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let bottomInset = topInset
            
            return UIEdgeInsetsMake(topInset, leftInset, bottomInset, rightInset)
        } else if tiles.count < 3 {
            let topInset = (collectionView.frame.height - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let bottomInset = topInset
            return UIEdgeInsetsMake(topInset, 10, bottomInset, 10)
        } else {
            return UIEdgeInsetsMake(10, 10, 0, 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = tilesView.dequeueReusableCell(withReuseIdentifier: "TileCell", for: indexPath) as? TileCell {
            let tile = indexPath.row < tiles.count ? tiles[indexPath.row] : nil
            cell.configureCell(tile: tile, delegate: self)
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
