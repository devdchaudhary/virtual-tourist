//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Devanshu on 27/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import Foundation
import CoreData

public class pinPhoto: NSManagedObject {
    
    convenience init(index:Int, url: String, image: NSData?, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: entity, insertInto: context)
            
            self.index = Int16(index)
            
            self.url = url
            
            self.image = image
            
        } else {
            
            fatalError("Unable To Find Entity Name!")
            
        }
    }

}


extension pinPhoto {
    
    public class func fetchRequest() -> NSFetchRequest<pinPhoto> {
        
        return NSFetchRequest<pinPhoto>(entityName: "Photo");
        
    }
    
    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var index: Int16
    @NSManaged public var pin: DroppedPin?

}
