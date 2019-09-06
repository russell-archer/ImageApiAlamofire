//
//  ViewController.swift
//  ImageApiAlamofire
//
//  Created by Russell Archer on 04/09/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pixabayHelper = PixabayHelper()
    var pixabayImages: [PixabayImage]?
    
    // Create a search controller, passing nil to indicate that results will be
    // displayed in the same view
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        // Add an integrated search controller to the navigation bar
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        // Ensure that the search bar does not remain on the screen if the user navigates to another
        // view controller while the UISearchController is active
        definesPresentationContext = true
        
        activityIndicator.startAnimating()
        
        // Load some default data
        pixabayHelper.loadImages(searchFor: "Kittens") { data in
            self.activityIndicator.stopAnimating()
            self.pixabayImages = data  // Cache the data returned to us
            self.imageCollectionView.reloadData()  // Refresh the collection of images
        }
    }
}

extension ViewController: UISearchResultsUpdating {
    // The UISearchResultsUpdating protocol allows us to be informed of text changes in UISearchBar
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        guard text != nil && text!.count > 2 else { return }
        
        pixabayImages = nil
        imageCollectionView.reloadData()
        activityIndicator.startAnimating()
        
        pixabayHelper.loadImages(searchFor: text!) { data in
            self.activityIndicator.stopAnimating()
            self.pixabayImages = data
            self.imageCollectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pixabayImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! CollectionViewCell
        
        guard pixabayImages != nil else { return cell }
        
        // Convert the preview URL in the data returned from Pixabay to a UIImage
        let url = URL(string: pixabayImages![(indexPath as NSIndexPath).row].webformatURL)
        if let imageData = try? Data(contentsOf: url!) {
            cell.previewImage.image = UIImage(data: imageData)!
        }
        
        return cell
    }
}
