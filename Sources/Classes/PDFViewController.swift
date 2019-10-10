//  PDFViewController.swift
//  PDFReader
//
//  Created by ALUA KINZHEBAYEVA on 4/19/15.
//  Copyright (c) 2015 AK. All rights reserved.
//

import UIKit

extension PDFViewController {
    /// Initializes a new `PDFViewController`
    ///
    /// - parameter document:            PDF document to be displayed
    /// - parameter title:               title that displays on the navigation bar on the PDFViewController; 
    ///                                  if nil, uses document's filename
    /// - parameter startPageIndex:      page index to start on load, defaults to 0; if out of bounds, set to 0
    ///
    /// - returns: a `PDFViewController`
    public class func createNew(with document: PDFDocument, title: String? = nil, startPageIndex: Int = 0) -> PDFViewController {
        let storyboard = UIStoryboard(name: "PDFReader", bundle: Bundle(for: PDFViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! PDFViewController
        controller.document = document
        
        if let title = title {
            controller.title = title
        } else {
            controller.title = document.fileName
        }
        
        if startPageIndex >= 0 && startPageIndex < document.pageCount {
            controller.currentPageIndex = startPageIndex
        } else {
            controller.currentPageIndex = 0
        }

        return controller
    }
}

/// Controller that is able to interact and navigate through pages of a `PDFDocument`
public final class PDFViewController: UIViewController {
    
    /// Collection veiw where all the pdf pages are rendered
    @IBOutlet public var collectionView: UICollectionView!
    
    /// Height of the thumbnail bar (used to hide/show)
    @IBOutlet private var thumbnailCollectionControllerHeight: NSLayoutConstraint!
    
    /// Distance between the bottom thumbnail bar with bottom of page (used to hide/show)
    @IBOutlet private var thumbnailCollectionControllerBottom: NSLayoutConstraint!
    
    /// Width of the thumbnail bar (used to resize on rotation events)
    @IBOutlet private var thumbnailCollectionControllerWidth: NSLayoutConstraint!
    
    /// PDF document that should be displayed
    private var document: PDFDocument!
    
    /// Current page being displayed
    private var currentPageIndex: Int = 0
    
    /// Bottom thumbnail controller
    private var thumbnailCollectionController: PDFThumbnailCollectionViewController?
    
    /// Background color to apply to the collectionView.
    public var backgroundColor: UIColor? = .lightGray {
        didSet {
            collectionView?.backgroundColor = backgroundColor
        }
    }
    
    public var thumbnailSelectedBorderColor: UIColor? = .red
    public var thumbnailCollectionBackgroundColor: UIColor? = .lightGray
    
    /// Reset page when its unpresented
    public var resetZoom: Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.backgroundColor = backgroundColor
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PDFThumbnailCollectionViewController {
            thumbnailCollectionController = controller
            controller.document = document
            controller.delegate = self
            controller.currentPageIndex = currentPageIndex
            controller.thumbnailCollectionBackgroundColor = thumbnailCollectionBackgroundColor
            controller.thumbnailSelectedBorderColor = thumbnailSelectedBorderColor
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            let currentIndexPath = IndexPath(row: self.currentPageIndex, section: 0)
            self.collectionView.reloadItems(at: [currentIndexPath])
            self.collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
            }) { context in
                self.thumbnailCollectionController?.currentPageIndex = self.currentPageIndex
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension PDFViewController: PDFThumbnailControllerDelegate {
    func didSelectIndexPath(_ indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        thumbnailCollectionController?.currentPageIndex = currentPageIndex
    }
}

extension PDFViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.pageCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! PDFPageCollectionViewCell
        cell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: document, pageCollectionViewCellDelegate: self)
        return cell
    }
}

extension PDFViewController: PDFPageCollectionViewCellDelegate {
    /// Toggles the hiding/showing of the thumbnail controller
    ///
    /// - parameter shouldHide: whether or not the controller should hide the thumbnail controller
    public func hideThumbnailController(_ shouldHide: Bool) {
        self.thumbnailCollectionControllerHeight.constant = shouldHide ? -thumbnailCollectionControllerHeight.constant : 0
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.reloadItems(at: [IndexPath(item: self.currentPageIndex, section: 0)])
            }
        }
    }
    
    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView) {
        var shouldHide: Bool {
            thumbnailCollectionControllerHeight.constant != 0
        }
        UIView.animate(withDuration: 0.25) {
            self.hideThumbnailController(shouldHide)
        }
    }
}

extension PDFViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 1, height: collectionView.frame.height)
    }
}

extension PDFViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let updatedPageIndex: Int
            updatedPageIndex = Int(round(max(scrollView.contentOffset.x, 0) / scrollView.bounds.width))
        
        if updatedPageIndex != currentPageIndex {
            if resetZoom {
                self.collectionView.reloadItems(at: [IndexPath(item: currentPageIndex, section: 0)])
            }
            currentPageIndex = updatedPageIndex
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
    }
}
