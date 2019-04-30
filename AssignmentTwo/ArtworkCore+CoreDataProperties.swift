//
//  ArtworkCore+CoreDataProperties.swift
//  AssignmentTwo
//
//  Created by Jahan on 29/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//
//

import Foundation
import CoreData


extension ArtworkCore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArtworkCore> {
        return NSFetchRequest<ArtworkCore>(entityName: "ArtworkCore")
    }
    @NSManaged public var artist: String?
    @NSManaged public var title: String?
    @NSManaged public var yearOfWork: String?
    @NSManaged public var information: String?
    @NSManaged public var locationNotes: String?



}
