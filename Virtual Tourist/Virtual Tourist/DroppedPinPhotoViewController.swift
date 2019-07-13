//
//  DroppedPinPhotoViewController.swift
//  Virtual Tourist
//
//  Created by Devanshu on 27/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import UIKit
import CoreData
import MapKit


class DroppedPinPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Outlets and Variables
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newcollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var coordinateSelected:CLLocationCoordinate2D!
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 25
    
    var stack:dataStack!
    var coreDataPin:DroppedPin!
    var savedImages:[pinPhoto] = []
    var selectedToDelete:[Int] = [] {
        
        didSet {
            
            if selectedToDelete.count > 0 {
                
                newcollectionButton.setTitle("Remove Selected Pictures", for: .normal)
                
            } else {
                
                newcollectionButton.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    func getCoreDataStack() -> dataStack {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        return delegate.datastack
        
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = getCoreDataStack()
        
        let filemanager = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        
        filemanager.sortDescriptors = []
        
        filemanager.predicate = NSPredicate(format: "pin = %@", argumentArray: [coreDataPin!])
        
        return NSFetchedResultsController(fetchRequest: filemanager, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func preloadSavedPhoto() -> [pinPhoto]? {
        
        do {
            
            var photoArray:[pinPhoto] = []
            
            let fetchedResultsController = getFetchedResultsController()
            
            try fetchedResultsController.performFetch()
            
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<photoCount {
                
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! pinPhoto)
            }
            
            return photoArray.sorted(by: {$0.index < $1.index})
            
        } catch {
            
            return nil
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        
        flowLayout.minimumLineSpacing = spacingBetweenItems
        
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        newcollectionButton.isHidden = false
        
        collectionView.allowsMultipleSelection = true
        
        addAnnotationToMap()
        
        let savedPhoto = preloadSavedPhoto()
        if savedPhoto != nil && savedPhoto?.count != 0 {
            savedImages = savedPhoto!
            
            showSavedResult()
            
        } else {
            
            showNewResult()
            
        }
        
    }
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
        if selectedToDelete.count > 0 {
            
            removeSelectedPicturesAtCoreData()
            unselectAllSelectedCollectionViewCell()
            savedImages = preloadSavedPhoto()!
            showSavedResult()
            
        } else {
            
            showNewResult()
            
        }
    
    }
    
    func unselectAllSelectedCollectionViewCell() {
        
        for indexPath in collectionView.indexPathsForSelectedItems! {
            
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
            
        }
        
    }
    
    func removeSelectedPicturesAtCoreData() {
        
        for index in 0..<savedImages.count {
            
            if selectedToDelete.contains(index) {
                
                getCoreDataStack().context.delete(savedImages[index])
            }
        }
        
        do {
            
            try getCoreDataStack().saveContext()
            
        } catch {
            
            debugPrint("Remove Core Data Photo Failed")
        }
        
        selectedToDelete.removeAll()
    }
    
    func showSavedResult() {
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
        }
        
    }
    
    func showNewResult() {
        
        newcollectionButton.isEnabled = false
        
        deleteExistingCoreDataPhoto()
        
        savedImages.removeAll()
        
        collectionView.reloadData()
        
        getFlickrImagesRandomResult { (flickrImages) in
            
            if flickrImages != nil {
                
                DispatchQueue.main.async {
                    
                    self.addCoreData(flickrImages: flickrImages!, coreDataPin: self.coreDataPin)
                    
                    self.savedImages = self.preloadSavedPhoto()!
                    
                    self.showSavedResult()
                    
                    self.newcollectionButton.isEnabled = true
                    
                }
                
            }
            
        }
        
    }
    
    func addCoreData(flickrImages:[FlickrImage], coreDataPin:DroppedPin) {
        
        for image in flickrImages {
            
            do {
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                
                let stack = delegate.datastack
                
                let photo = pinPhoto(index: flickrImages.index{$0 === image}!, url: image.imageURLString(), image: nil, context: stack.context)
                
                photo.pin = coreDataPin
                
                try stack.saveContext()
                
            } catch {
                
                print("Add Core Data Failed")
            }
            
        }
        
    }
    
    func deleteExistingCoreDataPhoto() {
        
        for image in savedImages {
            
            getCoreDataStack().context.delete(image)
            
        }
        
    }
    
    func getFlickrImagesRandomResult(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        
        FlickrClient.getFlickrImages(lat: coordinateSelected.latitude, lng: coordinateSelected.longitude) { (success, flickrImages) in
            if success {
                
                if flickrImages!.count > self.totalCellCount {
                    var randomArray:[Int] = []
                    
                    while randomArray.count < self.totalCellCount {
                        
                        let random = arc4random_uniform(UInt32(flickrImages!.count))
                        if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                    }
                    
                    for random in randomArray {
                        
                        result.append(flickrImages![random])
                    }
                    
                    completion(result)
                    
                } else {
                    
                    completion(flickrImages!)
                }
                
            } else {
                
                completion(nil)
                
            }
        }
    }
    
    func addAnnotationToMap() {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinateSelected
        
        mapView.addAnnotation(annotation)
        
        mapView.showAnnotations([annotation], animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return savedImages.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        cell.activityIndicator.startAnimating()
        
        cell.photoinitializer(savedImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return spacingBetweenItems
    }
    
    func selectedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int] {
        var selected:[Int] = []
        
        for indexPath in indexPathArray {
            
            selected.append(indexPath.row)
        }
        return selected
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            
            cell?.contentView.alpha = 0.5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            
            cell?.contentView.alpha = 1
            
        }
        
    }
    
}

