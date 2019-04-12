//
//  JsonStruct.swift
//  AssignmentTwoArtworks
//
//  Created by Jahan on 04/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import Foundation

struct Artwork: Decodable {
    
    let id: String
    let title: String?
    let artist: String?
    let yearOfWork: String?
    let Information: String?
    let lat: String
    let long: String
    var location: String?
    let locationNotes: String?
    let fileName: String?
    let lastModified: String?
    let enabled: String?
}

struct AllArtworks: Decodable {
    let campus_artworks: [Artwork]
}
