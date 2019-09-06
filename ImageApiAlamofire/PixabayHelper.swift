//
//  PixabayHelper.swift
//  ImageApiAlamofire
//
//  Created by Russell Archer on 04/09/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

/// Helper that uses Alamofire to perform an HTTP GET to request image data from Pixabay
class PixabayHelper: ObservableObject {
    fileprivate let plistHelper = PropertyFileHelper(file: "Pixabay")  // Allows us access to the Pixabay.plist config file
    fileprivate var currentSearchText = ""
    
    // Configuration data
    fileprivate var pixabayUrl: String
    fileprivate let pixabayApiKey: String
    fileprivate let pixabayImageType: String
    fileprivate let pixabayResultPerPage: String
    
    init() {
        // Read Pixabay parameters from a plist file
        pixabayUrl = plistHelper.readProperty(key: "url")!
        pixabayApiKey = plistHelper.readProperty(key: "key")!
        pixabayImageType = plistHelper.readProperty(key: "image_type")!
        pixabayResultPerPage = plistHelper.readProperty(key: "per_page")!
    }
    
    public func loadImages(searchFor: String, completion: @escaping (_ images: [PixabayImage]?) -> Void) {
        if searchFor == currentSearchText { return }
        currentSearchText = searchFor
        
        let params = ["key": pixabayApiKey, "image_type": pixabayImageType, "per_page": pixabayResultPerPage, "q": searchFor]
        
        // Make an HTPP GET request for image data
        Alamofire.request(pixabayUrl, method: .get, parameters: params)
        .validate(statusCode: 200..<300)  // Make sure we get a good HTTP 200 status code
        .validate(contentType: ["application/json"])  // Make sure the payload is JSON
        .responseJSON { response in
            guard response.result.isSuccess else { completion(nil); return }
            guard response.data != nil else { completion(nil); return }
            
            // Decode the JSON repsonse using iOS Foundation JSONDecoder
            let imageData = try? JSONDecoder().decode(PixabayData.self, from: response.data!)
            
            completion(imageData?.hits)  // Give the caller an array of image data
        }
    }
}


