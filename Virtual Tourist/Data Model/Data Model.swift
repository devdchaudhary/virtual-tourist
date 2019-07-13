//
//  Data Model.swift
//  Virtual Tourist
//
//  Created by Devanshu on 26/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import Foundation
import CoreData

struct dataStack {
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let databaseURL: URL
    let context: NSManagedObjectContext
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }
    
    init?(modelName: String) {
        
    guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            
        print("Unable To Find \(modelName).self In The Main Bundle")

        return nil
            
    }
        
        self.modelURL = modelURL
    
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            
            print("Unable To Create A Model From \(modelURL)")
            
            return nil
        }
        
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        context.persistentStoreCoordinator = coordinator
        
        let filemanager = FileManager.default
        
        guard let docURL = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            
            print("Unable to find Documents Folder")
            
            return nil
            
    }
        
        self.databaseURL = docURL.appendingPathComponent("Data Model.sqlite")
        
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            
          try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: options as [NSObject : AnyObject]?)
            
        } catch {
            
            print("Unable To Add Store At \(databaseURL)")

        }

    }
    
}
    
internal extension dataStack {
        
    func dropAllData() throws {
            
        try coordinator.destroyPersistentStore(at: databaseURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: databaseURL, options: nil)
            
        }
    
    func saveContext() throws {
        
        if context.hasChanges {
            
            try context.save()
        
       }
        
    }
    
    func autoSave(_ delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            
            do {
                
                try saveContext()
                
                print("Autosaving")
                
            } catch {
                
                print("Error While Autosaving")
                
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                self.autoSave(delayInSeconds)
                
      }
        
    }
        
  }

}
