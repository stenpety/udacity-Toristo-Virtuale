//
//  Photo+CoreDataProperties.swift
//  Toristo Virtuale
//
//  Created by Petr Stenin on 04/06/2017.
//  Copyright © 2017 Petr Stenin. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var photoURL: String?
    @NSManaged public var pin: Pin?

}
