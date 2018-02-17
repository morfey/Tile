//
//  EditTileViewController.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit
import Photos
import TTSegmentedControl

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
    @IBOutlet weak var sleepTimeStartTextField: UITextField!
    @IBOutlet weak var sleepTimeEndTextField: UITextField!
    @IBOutlet weak var segment: TTSegmentedControl!
    
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
    private var isChanged = false
    private var photoImages: NSMutableArray = []
    private var galleryImages: NSMutableArray = []
    private var totalImageCountNeeded: Int!
    private var tile: Tile!
    private var numberOfCellsPerRow = 3
    private var tileLoadedImage: UIImage!
    
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
        tile = router?.dataStore?.tile
        title = tile.name
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        
        sleepTimeStartTextField.delegate = self
        sleepTimeEndTextField.delegate = self
        sleepTimeStartTextField.text = tile.sleepTime.split(separator: "-").first?.trimmingCharacters(in: .whitespaces)
        sleepTimeEndTextField.text = tile.sleepTime.split(separator: "-").last?.trimmingCharacters(in: .whitespaces)
        initializeTextFieldInputView()
        
        imagePicker = UIImagePickerController()
        imagePicker.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        segment.itemTitles = ["Photo", "Gallery"]
        segment.allowChangeThumbWidth = false
        segment.thumbColor = .white
        segment.useGradient = false
        segment.selectedTextColor = .black
        segment.backgroundColor = #colorLiteral(red: 0.9511725307, green: 0.9610235095, blue: 0.9694404006, alpha: 1)
        segment.useShadow = false
        segment.defaultTextFont = UIFont.systemFont(ofSize: 17)
        segment.selectedTextFont = UIFont.systemFont(ofSize: 17)
        segment.didSelectItemWith = { (index, title) -> () in
            switch index {
            case 0:
                self.fetchPhotos()
            case 1:
                self.fetchGallery()
            default:
                break
            }
        }
        
        if let url = tile.imageUrl {
            let placeholder = #imageLiteral(resourceName: "empty_image").imageWithInsets(insetDimen: 30)
            originalImage.kf.setImage(with: URL(string: url), placeholder: placeholder, options: nil, progressBlock: nil)
            tileLoadedImage =  originalImage.image
        }
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.fetchPhotos()
                } else {
                    self.fetchGallery()
                }
            })
        } else {
            self.fetchPhotos()
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        originalImage.endEditing(true)
        let startSleep = sleepTimeStartTextField.text != "" ? sleepTimeStartTextField.text : sleepTimeStartTextField.placeholder
        let stopSleep = sleepTimeEndTextField.text != "" ? sleepTimeEndTextField.text : sleepTimeEndTextField.placeholder
        let sleepTime = (startSleep ?? "") + " - " + (stopSleep ?? "")
        if sleepTime != tile.sleepTime {
            FirebaseService.shared.update(tile: tile, sleepTime: sleepTime)
        }
        if let image = originalImage.image, image != tileLoadedImage {
            let request = EditTile.ImageForTile.Request(image: image)
            interactor?.saveImageForTile(request: request)
        } else {
            router?.routeToTiles(segue: nil)
        }
    }
    
    @IBAction func editImageBtnTapped(_ sender: Any) {
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        photoEditor.photoEditorDelegate = self
        photoEditor.gpuImagePlusDelegate = self
        photoEditor.hiddenControls = [.share, .save, .sticker, .draw]
        photoEditor.image = originalImage.image
        
        present(photoEditor, animated: true, completion: nil)
    }
    
    func proccessFilters(image: UIImage) -> ([CGImage]) {
        let worker = EditTileWorker()
        let images = worker.applyGPUImageFilters(originalImage: image)
        return images
    }
    
    func applyFilter(index: Int, toImage image: UIImage) -> UIImage? {
        return interactor?.applyGPUImageFilter(index: index, toImage: image)
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
    
    func fetchGallery() {
        if galleryImages.count == 0 {
            galleryImages = NSMutableArray()
            for i in 1...12 {
                if let image = UIImage(named: "\(i)") {
                    galleryImages.add(image as Any)
                }
            }
        }
        imagesCollectionView.reloadData()
    }
    
    func fetchPhotos () {
        if photoImages.count == 0 {
            photoImages = NSMutableArray()
            totalImageCountNeeded = 5
            fetchPhotoAtIndexFromEnd(index: 0)
        } else {
            imagesCollectionView.reloadData()
        }
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
                if let image = image {
                    self.photoImages.add(image)
                }
                if index + 1 < fetchResult.count && self.photoImages.count < self.totalImageCountNeeded {
                    self.fetchPhotoAtIndexFromEnd(index: index + 1)
                } else {
                    print("Completed array: \(self.photoImages)")
                    self.imagesCollectionView.reloadData()
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
            isChanged = true
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImage.image = image
            isChanged = true
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
        return segment.currentIndex == 0 ? photoImages.count + 1 : galleryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            if indexPath.row == 0 && segment.currentIndex == 0 {
                cell.configureCell(image: nil, first: true)
            } else if indexPath.row == photoImages.count && segment.currentIndex == 0 {
                let image = #imageLiteral(resourceName: "phoneGalleryButton")
                cell.configureCell(image: image, first: false)
            } else {
                let image = segment.currentIndex == 0 ? photoImages.object(at: indexPath.row) : galleryImages.object(at: indexPath.row)
                cell.configureCell(image: image as? UIImage, first: false)
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCell {
            if indexPath.row == 0 && segment.currentIndex == 0  {
                cameraPicker()
            } else if indexPath.row == photoImages.count && segment.currentIndex == 0 {
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
            } else {
                originalImage.image = cell.imageView.image!
                //                configure()
                isChanged = true
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
    
}

extension EditTileViewController: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        originalImage.image = image
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}
