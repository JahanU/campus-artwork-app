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

    var desArtworkDetail: Artwork? // Stores the report that was passed from view controller
    var cache: NSCache<NSString, NSData>?

    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblYearOfWork: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        lblAuthor.text = desArtworkDetail?.artist ?? "No Artist"
        lblTitle.text = desArtworkDetail?.title ?? "No Title"
        lblYearOfWork.text = desArtworkDetail?.yearOfWork ?? "No Year of work"
        lblInfo.text = desArtworkDetail?.Information ?? "No Information"

        if let key = desArtworkDetail?.fileName as NSString?,
            let image = cache?.object(forKey: key) as Data? {
            imageView.image = UIImage(data: image)
        }
    }
}
