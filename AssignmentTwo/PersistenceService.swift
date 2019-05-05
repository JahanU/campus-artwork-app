//
//  PersistenceService.swift
//  AssignmentTwo
//
//  Created by Jahan on 29/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext // This container stores all the things we would like to save
    }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "AssignmentTwo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext // As this stores everything the user wants to save, we then save this into our "Database/CoreData"
        if context.hasChanges {
            do {
                try context.save()
                 print("saved!")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func checkCoreData(aReportTitle: String) -> Bool { // Return true if the artwork is in core data already

        let fetchRequest: NSFetchRequest<ArtworkCore> = ArtworkCore.fetchRequest()

        do {
            let result = try persistentContainer.viewContext.fetch(fetchRequest)
            
            for data in result { // Loop through all the fav reports from CoreData
                let title = data.value(forKey: "title") as? String
                
                // If the entity matches the report given, get the favourite value.
                if (title == aReportTitle) {
                    print("matched")
                    return true
                }
            }
        }
        catch {
            print("Could not find favourite report")
        }
        
        return false // If it could not find the report, then return false
    }
    
    
//    static func unFave(aArtwork: ArtworkCore) {
//        // find the report that matches what they passed in.
//        // check if it matches core data, then delete it
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ArtworkCore")
//
//        // Finds a match given the report
//        let predicate = NSPredicate(format: "title = %@", aArtwork.title!)
//
//        fetch.predicate = predicate // Fetches the match result
//        let request = NSBatchDeleteRequest(fetchRequest: fetch) // Request to delete fav from core data
//        do {
//            try persistentContainer.viewContext.execute(request) // Execute the delete action into the coredata container
//        }
//        catch {
//            print("Cannot find report to delete")
//        }
//    }
    
    static func clearCoreData() { // Loops through core data and deletes all entities
        let fetchRequest: NSFetchRequest<ArtworkCore> = ArtworkCore.fetchRequest()
        do {
            let reports = try PersistenceService.context.fetch(fetchRequest)
            for obj in reports {
                PersistenceService.context.delete(obj as NSManagedObject)
            }
        }
        catch {
            print("Cannot clear core data")
        }
    }
    
}
