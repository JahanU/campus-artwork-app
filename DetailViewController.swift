//
//  DetailViewController.swift
//  AssignmentTwo
//
//  Created by Jahan on 12/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Property

    var fileName: Artwork? // Stores the report that was passed from view controller
    var desArtworkDetail: ArtworkCore?! // Stores the report that was passed from view controller
    var cache: NSCache<NSString, NSData>?

    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblYearOfWork: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblArtist: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = desArtworkDetail?.locationNotes ?? "No Location notes"
        lblTitle.text = desArtworkDetail?.title ?? "No title"
        lblArtist.text = "By " + (desArtworkDetail?.artist)! ?? "No Artist"
        lblYearOfWork.text = "Made in " + (desArtworkDetail?.yearOfWork)! ?? "No Year of work"
        lblInfo.text = desArtworkDetail?.information ?? "No Information"
        
        if let key = desArtworkDetail?.fileName as NSString?,
            let image = cache?.object(forKey: key) as Data? {
            imageView.image = UIImage(data: image)
        }
    }
}
