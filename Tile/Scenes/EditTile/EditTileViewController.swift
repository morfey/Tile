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
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    @IBOutlet weak var waitView: UIView!
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
    private var photoImages: [UIImage] = []
    private var galleryImages: NSMutableArray = []
    private var totalImageCountNeeded: Int!
    private var tile: Tile!
    private var numberOfCellsPerRow = 3
    private var tileLoadedImage: UIImage!
    private var localName: String?
    
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
        setupTitle(with: tile.name)
        
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
//        imagesCollectionView.
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func setupTitle(with name: String) {
        let titleView = UILabel()
        titleView.text = name
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(EditTileViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
    }
    
    @objc func titleWasTapped() {
        let alert = UIAlertController(title: "Change Tile name", message: "Enter new name", preferredStyle: .alert)
        alert.view.tintColor = #colorLiteral(red: 0.8919044137, green: 0.7269840837, blue: 0.4177360535, alpha: 1)
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.keyboardAppearance = .dark
        let action = UIAlertAction(title: "OK", style: .default) { act in
            self.localName = alert.textFields?.first?.text ?? "none"
            self.setupTitle(with: self.localName ?? self.tile.name)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        originalImage.endEditing(true)
        if let local = localName, tile.name != local {
            FirebaseService.shared.update(tile: tile, name: local)
        }
        let startSleep = sleepTimeStartTextField.text != "" ? sleepTimeStartTextField.text : sleepTimeStartTextField.placeholder
        let stopSleep = sleepTimeEndTextField.text != "" ? sleepTimeEndTextField.text : sleepTimeEndTextField.placeholder
        let sleepTime = (startSleep ?? "") + " - " + (stopSleep ?? "")
        if sleepTime != tile.sleepTime {
            FirebaseService.shared.update(tile: tile, sleepTime: sleepTime)
        }
        if let image = originalImage.image, image != tileLoadedImage {
            let request = EditTile.ImageForTile.Request(image: image)
            interactor?.saveImageForTile(request: request)
            waitView.isHidden = false
            activityIndecator.startAnimating()
        } else {
            router?.routeToTiles(segue: nil)
        }
    }
    
    @IBAction func editImageBtnTapped(_ sender: Any) {
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        photoEditor.photoEditorDelegate = self
        photoEditor.gpuImagePlusDelegate = self
        photoEditor.hiddenControls = [.share, .sticker, .draw]
        photoEditor.image = originalImage.image
        
        present(photoEditor, animated: true, completion: nil)
    }
    
    func proccessFilters(image: UIImage) -> ([CGImage]?) {
        return interactor?.applyGPUImageFilters(originalImage: image)
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
        autoreleasepool {
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
    }
    
    func fetchPhotos() {
        autoreleasepool {
            if photoImages.isEmpty {
                let fetcher = Fetcher()
                for i in 0..<4 {
                    fetcher.requestFullImageAtIndex(index: i, completion: { (image) in
                        self.photoImages.append(image)
                        if i >= 3 {
                            self.imagesCollectionView.reloadData()
                        }
                    })
                }
            } else {
                imagesCollectionView.reloadData()
            }
        }
//        photoImages.removeAll()
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
//        fetchOptions.fetchLimit = 4
//
//        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
//
//        if fetchResult.count > 0 {
//            let totalImageCountNeeded = 4
//            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
//        }
//        imagesCollectionView.reloadData()
    }

    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                self.photoImages += [image]
            }
            if index + 1 < fetchResult.count && self.photoImages.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            } else {
                print("Completed array: \(self.photoImages)")
            }
        })
    }
    
//    func fetchPhotos() {
//        photoImages = NSMutableArray()
//        totalImageCountNeeded = 4
//        let imgManager = PHImageManager.default()
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isSynchronous = true
//
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
//
//        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
//        fetchPhotoAtIndexFromEnd(index: 0, fetchResult: fetchResult, imgManager: imgManager, requestOptions: requestOptions)
//    }
//
//    func fetchPhotoAtIndexFromEnd(index:Int, fetchResult: PHFetchResult<PHAsset>, imgManager: PHImageManager, requestOptions: PHImageRequestOptions) {
//        if fetchResult.count > 0 {
//            imgManager.requestImage(for: fetchResult.object(at: fetchResult.count - 1 - index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
//                if let image = image {
//                    self.photoImages.add(image)
//                }
//                if index + 1 < fetchResult.count && self.photoImages.count < self.totalImageCountNeeded {
//                    self.fetchPhotoAtIndexFromEnd(index: index + 1, fetchResult: fetchResult, imgManager: imgManager, requestOptions: requestOptions)
//                } else {
//                    print("Completed array: \(self.photoImages)")
//                }
//            })
//        }
//        self.imagesCollectionView.reloadData()
//    }
    
    func displayTileWithImage(viewModel: EditTile.ImageForTile.ViewModel) {
        waitView.isHidden = true
        activityIndecator.stopAnimating()
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
extension EditTileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return segment.currentIndex == 0 ? photoImages.count + 2 : galleryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            if indexPath.row == 0 && segment.currentIndex == 0 {
                cell.configureCell(image: nil, first: true)
            } else if indexPath.row > photoImages.count && segment.currentIndex == 0 {
                let image = #imageLiteral(resourceName: "phoneGalleryButton")
                cell.configureCell(image: image, first: false)
            } else {
                let image = segment.currentIndex == 0 ? photoImages[indexPath.row - 1] : galleryImages.object(at: indexPath.row)
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
            } else if indexPath.row > photoImages.count && segment.currentIndex == 0 {
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true, completion: nil)
            } else {
                originalImage.image = cell.imageView.image
                isChanged = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let maxS = CGFloat(max(0, numberOfCellsPerRow - 1)) * horizontalSpacing
            var cellWidth = view.frame.width - maxS + (flowLayout.sectionInset.left * 2)
            cellWidth = cellWidth / CGFloat(numberOfCellsPerRow)
            collectionViewHeight.constant = (cellWidth + 10) * 2
            return CGSize(width: cellWidth, height: cellWidth)
        } else {
            return CGSize(width: 100, height: 100)
        }
    }
}

extension EditTileViewController: UITextFieldDelegate {
    func initializeTextFieldInputView() {
        // Add date picker
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let datePicker1 = UIDatePicker()
        datePicker1.datePickerMode = .time
        let startDate = sleepTimeStartTextField.text != nil && sleepTimeStartTextField.text != "" ? sleepTimeStartTextField.text! : sleepTimeStartTextField.placeholder!
        datePicker1.date = dateFormatter.date(from: startDate) ?? Date()
        datePicker1.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        sleepTimeStartTextField.inputView = datePicker1
        let endDate = sleepTimeEndTextField.text != nil && sleepTimeEndTextField.text != "" ? sleepTimeEndTextField.text! : sleepTimeEndTextField.placeholder!
        let datePicker2 = UIDatePicker()
        datePicker2.datePickerMode = .time
        datePicker2.date = dateFormatter.date(from: endDate) ?? Date()
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
