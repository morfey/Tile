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
    func displayTileWithImage(viewModel: EditTile.ImageForTile.ViewModel)
    func setImage(image: UIImage)
}

class EditTileViewController: UIViewController, EditTileDisplayLogic, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GPUimagePlusDelegate
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
    private var imagePicker: UIImagePickerController!
    private var angle: Double = 0.0
    private var imgSelected = false
    private var images: NSMutableArray!
    private var totalImageCountNeeded: Int!
    private var tile: Tile!
    private var numberOfCellsPerRow = 3
    
    @IBOutlet weak var sleepTimeStartTextField: UITextField!
    @IBOutlet weak var sleepTimeEndTextField: UITextField!
    
    
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
        sleepTimeStartTextField.delegate = self
        sleepTimeEndTextField.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        tile = router?.dataStore?.tile
        title = tile.name
        sleepTimeStartTextField.text = tile.sleepTime.split(separator: "-").first?.trimmingCharacters(in: .whitespaces)
        sleepTimeEndTextField.text = tile.sleepTime.split(separator: "-").last?.trimmingCharacters(in: .whitespaces)
        initializeTextFieldInputView()
        
        if let url = tile.imageUrl {
            let placeholder = #imageLiteral(resourceName: "empty_image").imageWithInsets(insetDimen: 30)
            originalImage.kf.setImage(with: URL(string: url), placeholder: placeholder, options: nil, progressBlock: nil)
        }
        fetchPhotos()
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        originalImage.endEditing(true)
        if let image = originalImage.image {
            let request = EditTile.ImageForTile.Request(image: image)
            interactor?.saveImageForTile(request: request)
        }
        
        let sleepTime = (sleepTimeStartTextField.text ?? "") + " - " + (sleepTimeEndTextField.text ?? "")
        if sleepTime != tile.sleepTime {
            FirebaseService.shared.update(tile: tile, sleepTime: sleepTime)
        }
    }
    
    @IBAction func editImageBtnTapped(_ sender: Any) {
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        photoEditor.photoEditorDelegate = self
        photoEditor.gpuImagePlusDelegate = self
        photoEditor.hiddenControls = [.share, .save, .sticker]
        photoEditor.image = originalImage.image
        
        present(photoEditor, animated: true, completion: nil)
    }
    
    func proccessFilters(image: UIImage) -> ([CGImage]) {
        let worker = EditTileWorker()
        let images = worker.applyGPUImageFilters(originalImage: image)
        return images
    }
    
    func applyFilter(index: Int, toImage image: UIImage) -> UIImage {
        let worker = EditTileWorker()
        return worker.applyGPUImageFilter(index: index, toImage: image)
    }
    
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
            imgSelected = true
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImage.image = image
            imgSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
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
// MARK: UICollectionViewDelegate & DataSource
extension EditTileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            if indexPath.row == 0 {
                cell.configureCell(image: nil, first: true)
            } else if indexPath.row == images.count {
                let image = #imageLiteral(resourceName: "phoneGalleryButton")
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let maxS = CGFloat(max(0, numberOfCellsPerRow - 1)) * horizontalSpacing
            var cellWidth = view.frame.width - maxS + (flowLayout.sectionInset.left * 2)
            cellWidth = cellWidth / CGFloat(numberOfCellsPerRow)
            return CGSize(width: cellWidth, height: cellWidth)
        } else {
            return CGSize(width: 100, height: 100)
        }
    }
}

extension EditTileViewController: UITextFieldDelegate {
    func initializeTextFieldInputView() {
        // Add date picker
        let datePicker1 = UIDatePicker()
        datePicker1.datePickerMode = .time
        datePicker1.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        sleepTimeStartTextField.inputView = datePicker1
        let datePicker2 = UIDatePicker()
        datePicker2.datePickerMode = .time
        datePicker2.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        sleepTimeEndTextField.inputView = datePicker2
        
        // Add toolbar with done button on the right
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35))
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        doneButton.tintColor = #colorLiteral(red: 0.8918183446, green: 0.7248821259, blue: 0.4182168841, alpha: 1)
        toolbar.items = [flexibleSeparator, doneButton]
        sleepTimeStartTextField.inputAccessoryView = toolbar
        sleepTimeEndTextField.inputAccessoryView = toolbar
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if datePicker == sleepTimeEndTextField.inputView {
            sleepTimeEndTextField.text = formatter.string(from: datePicker.date)
        } else if datePicker == sleepTimeStartTextField.inputView {
            sleepTimeStartTextField.text = formatter.string(from: datePicker.date)
        }
    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        view.endEditing(true)
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        view.endEditing(true)
//        guard let text = textField.text, text.count > 0 else { return false }
//        let matche = matches(for: "[0-9]{2}:[0-9]{2}[ ]-[ ][0-9]{2}:[0-9]{2}", in: text)
//        if matche.count > 0 {
//            FirebaseService.shared.update(tile: tile, sleepTime: matche.first!)
//        } else {
//            let alert = UIAlertController(title: "Error", message: "Time format must be\nхх:хх - хх:хх", preferredStyle: .alert)
//            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
//            alert.addAction(ok)
//            present(alert, animated: true, completion: nil)
//        }
//        return true
//    }
    
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
}

extension EditTileViewController: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        originalImage.image = image
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}
