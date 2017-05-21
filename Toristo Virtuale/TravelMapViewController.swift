//
//  TravelMapViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 07/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {
    
    // MARK: Properties
    var newAlbumLatitude: Double?
    var newAlbumLongitude: Double?
    
    // MARK: Outlets
    @IBOutlet weak var travelMapView: MKMapView!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Center map on user's current (or default) location
        let userCoordinates = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: Constants.userLatitude), longitude: UserDefaults.standard.double(forKey: Constants.userLongitude))
        let region = MKCoordinateRegionMakeWithDistance(userCoordinates, UserDefaults.standard.double(forKey: Constants.userMapScale), UserDefaults.standard.double(forKey: Constants.userMapScale))
        travelMapView.setRegion(region, animated: true)
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
                    print("Geocoding failed")
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
                self.travelMapView.addAnnotation(newAnnotation)
                print(newAnnotation.title!)
            })
        }
    }
}

