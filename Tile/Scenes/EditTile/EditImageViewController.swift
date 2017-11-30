//
//  EditTileViewController.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit
import Photos

protocol EditTileDisplayLogic: class
{
    func displayFiltersScrollView(viewModel: UIScrollView)
    func displayTileWithImage(viewModel: EditTile.ImageForTile.ViewModel)
    func filterButtonTapped(sender: UIButton)
    func setImage(image: UIImage)
}

class EditTileViewController: UIViewController, EditTileDisplayLogic, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, GPUimagePlusDelegate
{
    var interactor: EditTileBusinessLogic?
    var router: (NSObjectProtocol & EditTileRoutingLogic & EditTileDataPassing)?
    
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
    @IBOutlet weak var conteinerImage: UIView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    private func setup()
    {
        let viewController = self
        let interactor = EditTileInteractor()
        let presenter = EditTilePresenter()
        let router = EditTileRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
    var imagePicker: UIImagePickerController!
    var angle: Double = 0.0
    var imgSelected = false
    var images: NSMutableArray!
    var totalImageCountNeeded: Int!
    var tile: Tile!
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var lastPanPoint: CGPoint?
    
    @IBOutlet weak var sleepTimeTextField: UITextField!
    @IBOutlet weak var sleepTimePicker: UIDatePicker!
    
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        sleepTimeTextField.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        tile = router?.dataStore?.tile
        title = tile.name
        sleepTimeTextField.text = tile.sleepTime
        initializeTextFieldInputView()
        
        if let url = tile.imageUrl {
            originalImage.kf.setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "FullImage"), options: nil, progressBlock: nil)
        }
        fetchPhotos()
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        originalImage.endEditing(true)
        if let image = originalImage.image != nil ? originalImage.toImage() : originalImage.image {
            let request = EditTile.ImageForTile.Request(image: image)
            interactor?.saveImageForTile(request: request)
        }
    }
    
    @IBAction func editImageBtnTapped(_ sender: Any) {
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        photoEditor.photoEditorDelegate = self
        photoEditor.gpuImagePlusDelegate = self
        photoEditor.hiddenControls = [.share, .save]
        photoEditor.image = originalImage.image
        
        present(photoEditor, animated: true, completion: nil)
    }
    
    func filterButtonTapped(sender: UIButton) {
//        
    }
    
    func proccessFilters(image: UIImage) -> ([CGImage]) {
        let worker = EditTileWorker()
        let images = worker.applyGPUImageFilters(originalImage: image)
        return images
    }
    
//    func configure() {
//        imageCropperView.image = originalImage.image!
//        let request = EditImage.Filters.Request(filters: CIFilterNames, originalImage: originalImage.image!)
//        interactor?.applyFilters(request: request)
//    }
    
    func cameraPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func setImage(image: UIImage) {
        originalImage.image = image
    }
    
    func displayFiltersScrollView(viewModel: UIScrollView) {
//        activityIndicator.stopAnimating()
//        viewModel.subviews.forEach {
//            filtersScrollView.addSubview($0)
//        }
//        filtersScrollView.contentSize = viewModel.contentSize
    }
    
    func fetchPhotos () {
        images = NSMutableArray()
        totalImageCountNeeded = 5
        fetchPhotoAtIndexFromEnd(index: 0)
    }
    
    func fetchPhotoAtIndexFromEnd(index:Int) {
        
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        if fetchResult.count > 0 {
            imgManager.requestImage(for: fetchResult.object(at: fetchResult.count - 1 - index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                self.images.add(image!)
                if index + 1 < fetchResult.count && self.images.count < self.totalImageCountNeeded {
                    self.fetchPhotoAtIndexFromEnd(index: index + 1)
                } else {
                    print("Completed array: \(self.images)")
                }
            })
        }
    }
    
    func displayTileWithImage(viewModel: EditTile.ImageForTile.ViewModel) {
        router?.routeToTiles(segue: nil)
    }
    
    // MARK: UIImagePicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            originalImage.image = image
//            configure()
            imgSelected = true
//            effectsView.isHidden = true
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImage.image = image
//            configure()
            imgSelected = true
//            effectsView.isHidden = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDelegate & DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            if indexPath.row == 0 {
                cell.configureCell(image: nil, first: true)
            } else if indexPath.row == images.count {
                let image = UIImage(named: "FullImage.png")
                cell.configureCell(image: image, first: false)
            } else {
                cell.configureCell(image: images.object(at: indexPath.row) as? UIImage, first: false)
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
            if indexPath.row == 0 {
                cameraPicker()
            } else if indexPath.row == images.count {
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
            } else {
                originalImage.image = cell.imageView.image!
//                configure()
                imgSelected = true
//                effectsView.isHidden = true
            }
        }
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
}

extension EditTileViewController: UITextFieldDelegate {
    func initializeTextFieldInputView() {
        // Add date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        sleepTimeTextField.inputView = datePicker
        
        // Add toolbar with done button on the right
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10))
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        toolbar.items = [flexibleSeparator, doneButton]
        sleepTimeTextField.inputAccessoryView = toolbar
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        sleepTimeTextField.text = formatter.string(from: datePicker.date)
    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        sleepTimePicker.isHidden = true
        return true
    }
}

extension EditTileViewController: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        originalImage.image = image
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}
