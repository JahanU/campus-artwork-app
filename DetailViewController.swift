//
//  DetailViewController.swift
//  AssignmentTwo
//
//  Created by Jahan on 12/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var desArtworkDetail: Artwork? // Stores the report that was passed from view controller
    @IBOutlet weak var lblArtist, lblTitle, lblYearWork, lblInformation: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        lblArtist.text = desArtworkDetail?.artist ?? "No Artist"
        lblTitle.text = desArtworkDetail?.title ?? "No Title"
        lblYearWork.text = desArtworkDetail?.yearOfWork ?? "No Year of work"
        lblInformation.text = desArtworkDetail?.Information ?? "No Information"

       
    }


}
