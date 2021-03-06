//
//  CSPhotoGalleryAssetCollectionViewController.swift
//  CSPhotoGallery
//
//  Created by Naver on 2016. 12. 13..
//  Copyright © 2016년 Youk Chansim. All rights reserved.
//

import UIKit
import Photos

class CSPhotoGalleryAssetCollectionViewController: UIViewController {
    static var instance: CSPhotoGalleryAssetCollectionViewController {
        let podBundle = Bundle(for: CSPhotoGalleryAssetCollectionViewController.self)
        let bundleURL = podBundle.url(forResource: "CSPhotoGallery", withExtension: "bundle")
        let bundle = bundleURL == nil ? podBundle : Bundle(url: bundleURL!)
        let storyBoard = UIStoryboard(name: "CSPhotoGallery", bundle: bundle)
        return storyBoard.instantiateViewController(withIdentifier: identifier) as! CSPhotoGalleryAssetCollectionViewController
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    
    var viewHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setViewController()
    }
    
    deinit {
        PhotoManager.sharedInstance.remover(object: self)
        NSLog("Deinit \(self)")
    }
}

extension CSPhotoGalleryAssetCollectionViewController {
    fileprivate func setViewController() {
        setData()
        setView()
    }
    
    private func setView() {
        
    }
    
    private func setData() {
        PhotoManager.sharedInstance.register(object: self)
    }
}

//  MARK:- ViewController Extension
extension CSPhotoGalleryAssetCollectionViewController {
    fileprivate func appear() {
        showView(height: viewHeight)
    }
    
    fileprivate func disappear() {
        showView(height: 0)
    }
    
    private func showView(height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.frame.size.height = height
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
}

//  MARK:- TableView DataSource
extension CSPhotoGalleryAssetCollectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .smartAlbums: return PhotoManager.sharedInstance.smartAlbumsCount
        case .userCollections: return PhotoManager.sharedInstance.userCollectionsCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as CSPhotoGalleryAssetCollectionViewCell
        var collection: PHAssetCollection?
        
        switch Section(rawValue: indexPath.section)! {
        case .smartAlbums:
            collection = PhotoManager.sharedInstance.getSmartAlbumsAssetCollection(index: indexPath.item)
        case .userCollections:
            collection = PhotoManager.sharedInstance.getUserCollection(index: indexPath.item)
        }
        
        cell.setAlbumImage(image: nil)
        cell.indexPath = indexPath
        cell.albumName.text = collection!.localizedTitle
        cell.albumAssetCount.text = "\(PhotoManager.sharedInstance.getPHAssetCollectionCount(collection: collection!))"
        
        let asset = PhotoManager.sharedInstance.getAssetsInPHAssetCollection(collection: collection!).object(at: 0)
        let size = cell.bounds.width * 3
        
        PhotoManager.sharedInstance.assetToImage(asset: asset, imageSize: CGSize(width: size, height: size), isCliping: true) { image in
            if cell.indexPath == indexPath {
                cell.setAlbumImage(image: image)
            }
        }
        
        return cell
    }
}

//  MARK:- TableView Delegate
extension CSPhotoGalleryAssetCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var collection: PHAssetCollection?
        
        switch Section(rawValue: indexPath.section)! {
        case .smartAlbums:
            collection = PhotoManager.sharedInstance.getSmartAlbumsAssetCollection(index: indexPath.item)
        case .userCollections:
            collection = PhotoManager.sharedInstance.getUserCollection(index: indexPath.item)
        }
        
        PhotoManager.sharedInstance.currentCollection = collection
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension CSPhotoGalleryAssetCollectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            PhotoManager.sharedInstance.initSmartAlbumCollection()
            PhotoManager.sharedInstance.initUserCollection()
            self.tableView.reloadData()
        }
    }
}

