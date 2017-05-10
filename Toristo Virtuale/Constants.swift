//
//  Constants.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 10/05/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation

struct Constants {
    
    // Empty private init to prohibit initialization of this struct
    private init() {}
    
    // Storyboard Identifiers
    static let segueShowPhotoAlbum = "showPhotoAlbum"
    static let photoAlbumCollectionItem = "photoAlbumCollectionItem"
    
    // Flickr app id
    static let flickrAppID = ""
    
    // UserDefaults keys
    static let hasLaunchedBefore = "hasLaunchedBefore"
    static let userLatitude = "userLAtitude"
    static let userLongitude = "userLongitude"
    static let userMapScale = "userMapScale"
    
    // Auxiliary items
    static let defaultMapScale: Double = 500000
    static let defaultLatitude = -37.814
    static let defaultLongitude = 144.96332
    
}