//
//  DroppedPin.swift
//  Virtual Tourist
//
//  Created by Devanshu on 27/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import Foundation
import CoreData

public class DroppedPin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: entity, insertInto: context)
            
            self.latitude = latitude
            
            self.longitude = longitude
            
        } else {
        
            fatalError("Unable To Find Entity Name!")
            
        }
        
    }
    
}

extension DroppedPin {
    
    public class func fetchRequest() -> NSFetchRequest<DroppedPin> {
        
        return NSFetchRequest<DroppedPin>(entityName: "Pin");
        
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: NSSet?
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: pinPhoto)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: pinPhoto)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
    
}
