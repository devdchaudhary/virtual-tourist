//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Devanshu on 25/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    // Outlets and Variables
    
    @IBOutlet weak var mapPins: MKMapView!
    
    var droppedPins:[DroppedPin] = []
    var gestureBegin: Bool = false
    var editMode: Bool = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setRightBarButtonItem()
        
        let savedPins = preloadsavedPin()
        
        if savedPins != nil {
            
            droppedPins = savedPins!
            
            for pin in droppedPins {
                
                let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotationToMap(fromCoord: coord)
                
        }
            
    }
        
}
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        editMode = editing
        
    }
    
    func coredataStack() -> dataStack {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        return delegate.datastack
        
    }
    
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = coredataStack()
        
        let filemanager = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        filemanager.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: filemanager, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func preloadsavedPin() -> [DroppedPin]? {
        
        do {
            
            var pinArray:[DroppedPin] = []
            
            let fetchedResultsController = getFetchedResultsController()
            
            try fetchedResultsController.performFetch()
            
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<pinCount {
                
                pinArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! DroppedPin)
            }
            
            return pinArray
            
        } catch {
            
            return nil
        }
        
    }
    
    func setRightBarButtonItem() {
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !editMode {
            
            performSegue(withIdentifier: "pinPhoto", sender: view.annotation?.coordinate)
            
            mapView.deselectAnnotation(view.annotation, animated: false)
            
        } else {
            
            removeCoreData(of: view.annotation!)
            
            mapView.removeAnnotation(view.annotation!)
        }
        
    }
    
    @IBAction func longtapResponse(_ sender: Any) {
        
        if gestureBegin {
            
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            
            let gestureTouchLocation = gestureRecognizer.location(in: mapPins)
            
            addAnnotationToMap(fromPoint: gestureTouchLocation)
            
            gestureBegin = false
            
            debugPrint("Gesture recognised")
        }
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        gestureBegin = true
        
        return true
        
    }
    
    func addAnnotationToMap(fromPoint: CGPoint) {
        
        let coordToAdd = mapPins.convert(fromPoint, toCoordinateFrom: mapPins)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordToAdd
        
        addCoreData(of: annotation)
        
        mapPins.addAnnotation(annotation)
        
    }
    
    func addAnnotationToMap(fromCoord: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = fromCoord
        
        mapPins.addAnnotation(annotation)
        
    }
    
    func addCoreData(of: MKAnnotation) {
        
        do {
            
            let coord = of.coordinate
            
            let pin = DroppedPin(latitude: coord.latitude, longitude: coord.longitude, context: coredataStack().context)
            
            try coredataStack().saveContext()
            
            droppedPins.append(pin)
            
        } catch {
            
            print("Add Core Data Failed")
        }
        
    }
    
    func removeCoreData(of: MKAnnotation) {
        
        let coord = of.coordinate
        
        for pin in droppedPins {
            
            if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                
                do {
                    
                    coredataStack().context.delete(pin)
                    try coredataStack().saveContext()
                    
                } catch {
                    
                    print("Remove Core Data Failed")
                }
                
                break
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pinPhoto" {
            
            let destination = segue.destination as! DroppedPinPhotoViewController
            
            let coord = sender as! CLLocationCoordinate2D
            
            destination.coordinateSelected = coord
            
            for pin in droppedPins {
                
                if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                    
                  destination.coreDataPin = pin
                    
                    break
                    
                }
                
            }
            
        }
        
    }
}

