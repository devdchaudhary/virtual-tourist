//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Devanshu on 26/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import Foundation

class FlickrClient {
    
   static func getFlickrImages(lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ flickrImages:[FlickrImage]?) -> Void) {
    
    let request = NSMutableURLRequest(url: URL(string: "\(FlickrClient.Flickr.APIHost)?method=\(FlickrClient.FlickrParameterValues.SearchMethod)&format=\(FlickrClient.FlickrParameterValues.ResponseFormat)&api_key=\(FlickrClient.FlickrParameterValues.APIKey)&lat=\(lat)&lon=\(lng)&radius=\(FlickrClient.Flickr.searchRangeKM)")!)
    
    let session = URLSession.shared
    
    let task = session.dataTask(with: request as URLRequest) { data, response, error in
        
        if error != nil {
            
            completion(false, nil)
            return
        }
        
        let range = Range(uncheckedBounds: (14, data!.count - 1))
        let newData = data?.subdata(in: range)
        
        if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
            let photosMeta = json?["photos"] as? [String:Any],
            let photos = photosMeta["photo"] as? [Any] {
            
            var flickrImages:[FlickrImage] = []
            
            for photo in photos {
                
                if let flickrImage = photo as? [String:Any],
                    let id = flickrImage["id"] as? String,
                    let secret = flickrImage["secret"] as? String,
                    let server = flickrImage["server"] as? String,
                    let farm = flickrImage["farm"] as? Int {
                    flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                }
            }
            
            completion(true, flickrImages)
            
        } else {
            
            completion(false, nil)
        }
    }
    
    task.resume()
    
    }
    
}
