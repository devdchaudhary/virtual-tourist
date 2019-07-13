//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Devanshu on 25/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import UIKit

extension FlickrClient {
    
    struct Flickr {
        
        static let APIHost = "https://api.flickr.com/services/rest/"
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        static let searchRangeKM = 10
        
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        
    }
    
    struct FlickrParameterValues {
        
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "82cf5bccd31564354e5d980030c7126e"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        
    }
    
    struct FlickrResponseKeys {
        
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    struct FlickrResponseValues {
        
        static let OKStatus = "ok"
        
    }

}
