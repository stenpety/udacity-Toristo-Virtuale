//
//  TravelMapViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 07/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    // MARK: Properties
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        // TODO: Do I really need this didSet?
        didSet {
            fetchedResultsController?.delegate = self
            // TODO: Execute search
            // TODO: reload map data?
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Outlets
    @IBOutlet weak var travelMapView: MKMapView!
    
    // MARK: Initializers
    init (fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check whether the app has been launcehd before. Set user coordinates to defaults otherwise
        if !UserDefaults.standard.bool(forKey: Constants.hasLaunchedBefore) {
            UserDefaults.standard.set(true, forKey: Constants.hasLaunchedBefore)
            UserDefaults.standard.set(Constants.defaultLatitude, forKey: Constants.userLatitude)
            UserDefaults.standard.set(Constants.defaultLongitude, forKey: Constants.userLongitude)
            UserDefaults.standard.set(Constants.defaultMapScale, forKey: Constants.userMapScale)
            UserDefaults.standard.synchronize()
        }
        
        // Add Long Press gesture recognizer
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        longPressGR.minimumPressDuration = Constants.defaultMinPressDuration //Set press duration
        travelMapView.addGestureRecognizer(longPressGR) //Add gesture recognizer to the mapView
        
        // Assign mapView delegate
        travelMapView.delegate = self
        
        // CoreData stuff
        // Get the stack
        
        let stack = appDelegate.stack //CoreData stack of AppDelegate singleton
        
        // Create a Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.pinEntity)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.keyLocationNameForPin, ascending: true)]
        
        // Create a Fetched results controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Center map on user's current (or default) location
        let userCoordinates = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: Constants.userLatitude), longitude: UserDefaults.standard.double(forKey: Constants.userLongitude))
        let region = MKCoordinateRegionMakeWithDistance(userCoordinates, UserDefaults.standard.double(forKey: Constants.userMapScale), UserDefaults.standard.double(forKey: Constants.userMapScale))
        travelMapView.setRegion(region, animated: true)
        
        // Load annotations from CoreData store
        var annotations = [MKPointAnnotation]()
        let frAnnot = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.pinEntity)
        let moc = fetchedResultsController!.managedObjectContext
        
        do {
            let result = try moc.fetch(frAnnot)
            for object in result {
                if object is Pin {
                    let annotation = MKPointAnnotation()
                    let pin = object as! Pin
                    annotation.coordinate.latitude = pin.latitude
                    annotation.coordinate.longitude = pin.longitude
                    annotation.title = pin.locationName
                    annotations.append(annotation)
                }
            }
        } catch {
            fatalError("Cannot fetch any Pins")
        }
        
        travelMapView.addAnnotations(annotations)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save current map position to UserDefaults
        UserDefaults.standard.set(travelMapView.region.center.latitude, forKey: Constants.userLatitude)
        UserDefaults.standard.set(travelMapView.region.center.longitude, forKey: Constants.userLongitude)
        UserDefaults.standard.set(travelMapView.region.span.latitudeDelta * Constants.metersInOneLatDegree, forKey: Constants.userMapScale)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Actions
    func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            // Get coordinates of touch point
            let pointOfTouch = gestureRecognizer.location(in: travelMapView)
            let pointCoordinates = travelMapView.convert(pointOfTouch, toCoordinateFrom: travelMapView)
            
            // Make a new annotation
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = pointCoordinates
            
            // Get a name for new location
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: pointCoordinates.latitude, longitude: pointCoordinates.longitude ), completionHandler: {(placemarks, error) -> Void in
                
                guard error == nil, let placemarkArray = placemarks else {
                    General.sharedInstance.showAlert(self, title: "Geocoding failed", message: "Unable to return a geocode for the selected location", actionTitle: Constants.alertDismiss)
                    return
                }
                
                if placemarkArray.count > 0 {
                    let placemark = placemarkArray[0]
                    
                    if let thoroughfare = placemark.thoroughfare {
                        newAnnotation.title = thoroughfare
                    } else {
                        newAnnotation.title = Constants.defaultLocationName
                    }
                    if let subLocality = placemark.subLocality {
                        newAnnotation.subtitle = subLocality
                    } else {
                        newAnnotation.subtitle = Constants.defaultLocalityName
                    }
                } else {
                    newAnnotation.title = Constants.defaultLocationName
                    newAnnotation.subtitle = Constants.defaultLocalityName
                }
                // Make new CoreData item (pin) - in the main queue?
                let newPin = Pin(latitude: pointCoordinates.latitude, longitude: pointCoordinates.longitude, locationName: newAnnotation.title, context: self.fetchedResultsController!.managedObjectContext)
                self.travelMapView.addAnnotation(newAnnotation)
                self.appDelegate.stack.save()
                self.bringUpPhotoAlbum(forPin: newPin)
            })
        }
    }
    
    // MARK: Navigation
    func bringUpPhotoAlbum(forPin pin: Pin) {
        let photoAlbumViewController = storyboard!.instantiateViewController(withIdentifier: Constants.photoAlbumViewController) as! PhotoAlbumViewController
        photoAlbumViewController.pinForAlbum = pin
        navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
    
    // MARK: MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // TODO: Find already exsisting pin: Fetch request - predicate on lat&long -> get Pin
        let usedPinFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.pinEntity) // FR for pin
        usedPinFetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.keyLocationNameForPin, ascending: true)]
        
        let usedPinPred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude])
        usedPinFetchRequest.predicate = usedPinPred
        let moc = fetchedResultsController!.managedObjectContext
        do {
            let usedPinArray = try moc.fetch(usedPinFetchRequest)
            let usedPin = usedPinArray[0] as! Pin
            bringUpPhotoAlbum(forPin: usedPin)
        } catch {
            fatalError("CANNOT find a proper pin")
        }
    }
}

