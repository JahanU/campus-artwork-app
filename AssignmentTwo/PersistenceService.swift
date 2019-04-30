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
