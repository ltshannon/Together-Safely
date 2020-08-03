//
//  CoreDataManager.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/25/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    init() {}
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlacesTest")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Unresolved error \($0)") }
        })
        return container
    }()
        
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
        
    func loadDataPoints() -> [DataPoints] {
        let mainContext = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<DataPoints> = DataPoints.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            return results
        }
        catch {
            debugPrint(error)
        }
        return []
    }
        
    func saveDataPoints(timeStamp: Date, lat: CLLocationDegrees, lng: CLLocationDegrees) {
        let context = CoreDataManager.shared.backgroundContext()
        context.perform {
            do {
                let entity = DataPoints.entity()
                let dataPoint = DataPoints(entity: entity, insertInto: context)
                dataPoint.lat = lat
                dataPoint.lng = lng
                dataPoint.timeStamp = timeStamp
            try context.save()
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }

    func loadPlaces() -> [Places] {
        let mainContext = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<Places> = Places.fetchRequest()
        do {
            let results = try mainContext.fetch(fetchRequest)
            return results
        }
        catch {
            debugPrint(error)
        }
        return []
    }
        
    func savePlaces(name: String, placeId: String, type: String, lat: CLLocationDegrees, lng: CLLocationDegrees, timeStamp: Date) {
        let context = CoreDataManager.shared.backgroundContext()
        context.perform {
            do {
                let entity = Places.entity()
                let place = Places(entity: entity, insertInto: context)
                place.name = name
                place.placeId = placeId
                place.type = type
                place.lat = lat
                place.lng = lng
                place.timeStamp = timeStamp
            try context.save()
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}
