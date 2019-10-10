//
//  StartViewController.swift
//  PDFReader
//
//  Created by Ricardo Nunez on 7/8/16.
//  Copyright © 2016 AK. All rights reserved.
//

import UIKit
import PDFReader

/// Presents user with some documents which can be viewed
internal final class StartViewController: UIViewController {
    /// Displays a smaller sized PDF document
    @IBAction private func showSmallPDFDocument() {
        let smallPDFDocumentName = "apple"
        if let doc = document(smallPDFDocumentName) {
            showDocument(doc)
        } else {
            print("Document named \(smallPDFDocumentName) not found in the file system")
        }
    }
    
    /// Displays a larger sized PDF document
    @IBAction private func showRemotePDFDocument() {
        let remotePDFDocumentURLPath = "http://static-prime.nyposttabletapps.com/issues/ea6ba2ae74b4216188708d3bd1e19563.pdf"
        if let remotePDFDocumentURL = URL(string: remotePDFDocumentURLPath), let doc = document(remotePDFDocumentURL) {
            showDocument(doc)
        } else {
            print("Document named \(remotePDFDocumentURLPath) not found")
        }
    }
    
    /// Displays an insanely large sized PDF document
    @IBAction private func showInsanelyLargePDFDocument() {
        let insanelyLargePDFDocumentName = "javaScript"
        if let doc = document(insanelyLargePDFDocumentName) {
            showDocument(doc)
        } else {
            print("Document named \(insanelyLargePDFDocumentName) not found in the file system")
        }
    }
    
    /// Initializes a document with the name of the pdf in the file system
    private func document(_ name: String) -> PDFDocument? {
        guard let documentURL = Bundle.main.url(forResource: name, withExtension: "pdf") else { return nil }
        return PDFDocument(url: documentURL)
    }
    
    /// Initializes a document with the data of the pdf
    private func document(_ data: Data) -> PDFDocument? {
        return PDFDocument(fileData: data, fileName: "Sample PDF")
    }
    
    /// Initializes a document with the remote url of the pdf
    private func document(_ remoteURL: URL) -> PDFDocument? {
        return PDFDocument(url: remoteURL)
    }
    
    
    /// Presents a document
    ///
    /// - parameter document: document to present
    private func showDocument(_ document: PDFDocument) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        let someDateTime = formatter.string(from: date)
        
        let controller = PDFViewController.createNew(with: document, title: someDateTime, startPageIndex: 0)
        controller.backgroundColor = .white
        controller.thumbnailSelectedBorderColor = .yellow
        controller.thumbnailCollectionBackgroundColor = .black
        navigationController?.pushViewController(controller, animated: true)
        
        //controller.hideThumbnailController(true)
    }

}
