//
//  PhotoAlbumViewController.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    var numberOfCellsInRow = Constants.initialNumberOfCellsInRow // Set to initial value 3
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pinForAlbum: Pin? = nil //Values to be obtained from TravelMapVC
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            // TODO: Execute search
            photoAlbumCollectionView.reloadData()
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var auxMapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var photoAlbumFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: Initializers
    init (fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Collection view
        setupFlowLayout()
        photoAlbumCollectionView.delegate = self
        photoAlbumCollectionView.dataSource = self
        
        // Set the title of this view
        title = Constants.collectionViewTitle
        
        // Get the CoreData stack (from AppDelegate)
        let stack = appDelegate.stack
        
        // Create a FetchRequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.photoEntity)
        fr.sortDescriptors = [NSSortDescriptor(key: Constants.keyPhotoURLForPhoto, ascending: true)]
        
        // Setup FetchedRequestController (which context??)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Download pictures URLs
        // Check whether 'pin' data were obtained
        guard let pinInUse = pinForAlbum else {
            // TODO: Show alert - pin data were not transmitted
            return
        }
        
        let flickrDownloader = FlickrDownloader()
        flickrDownloader.downloadImagesByCoordinates(latitude: pinInUse.latitude, longitude: pinInUse.longitude, completionHandlerForDownload: {(urlArray, error) in
            // TODO: Save array of picture URLs to CoreData store
            
            
        })
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup mini-map & label
        // Check whether 'pin' data were obtained. Otherwise this all is meaningless
        guard let pinInUse = pinForAlbum else {
            // TODO: Error, perhaps fatal
            return
        }
        locationNameLabel.text = pinInUse.locationName
        
        // Center mini-map on user's new pin location:
        let pinInUseCoordinates = CLLocationCoordinate2D(latitude: pinInUse.latitude, longitude: pinInUse.longitude)
        let region = MKCoordinateRegionMakeWithDistance(pinInUseCoordinates, Constants.defaultMiniMapScale, Constants.defaultMiniMapScale)
        auxMapView.setRegion(region, animated: false)
        
        // Set a pin
        let miniMapPin = MKPointAnnotation()
        miniMapPin.coordinate = pinInUseCoordinates
        miniMapPin.title = pinInUse.locationName
        auxMapView.addAnnotation(miniMapPin)
        
        // Download images using URL
        photoAlbumCollectionView.reloadData() // Reload collection to reflect changes
    }
    
    // MARK: Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // TODO: Get the number of sections from the DB
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoAlbumCollectionItem, for: indexPath) as! PhotoAlbumCollectionViewCell
        //TODO: Setup the cell - put image from DB
        
        return cell
    }
    
    // MARK: Actions
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: delete an item
    }
    
    
    // MARK: Auxiliary procedures
    func setupFlowLayout() {
        // Setup Inter-item & line spacing to defaults
        photoAlbumFlowLayout.minimumInteritemSpacing = Constants.collectionMinInteritemSpace
        photoAlbumFlowLayout.minimumLineSpacing = Constants.collectionMinLineSpace
        
        // Set item width with respect to the number of items in row
        let dimension = ((photoAlbumCollectionView.frame.size.width) - CGFloat(numberOfCellsInRow - 1) * Constants.collectionMinInteritemSpace) / CGFloat(numberOfCellsInRow)
        photoAlbumFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
