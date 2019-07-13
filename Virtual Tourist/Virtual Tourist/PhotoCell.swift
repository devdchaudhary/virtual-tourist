//
//  File.swift
//  Virtual Tourist
//
//  Created by Devanshu on 29/06/18.
//  Copyright © 2018 Devanshu. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    func saveImageDataToCoreData(photo: pinPhoto, image: NSData) {
        
        do {
            
            photo.image = image
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            
            let stack = delegate.datastack
            
            try stack.saveContext()
            
        } catch {
            
            debugPrint("Saving Photo imageData Failed")
            
        }
    }
    
    func downloadImage(_ photo: pinPhoto) {
        
        URLSession.shared.dataTask(with: URL(string: photo.url!)!) { (data, response, error) in
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    self.imageView.image = UIImage(data: data! as Data)
                    self.activityIndicator.stopAnimating()
                    self.saveImageDataToCoreData(photo: photo, image: data! as NSData)
                }
            }
            
            }
            
            .resume()
        
    }
    
    
    func photoinitializer(_ photo: pinPhoto) {
        
        if photo.image != nil {
            
            DispatchQueue.main.async {
                
                self.imageView.image = UIImage(data: photo.image! as Data)
                
                self.activityIndicator.stopAnimating()
                
            }
            
        } else {
            
        downloadImage(photo)
            
        }
        
    }
    
}
