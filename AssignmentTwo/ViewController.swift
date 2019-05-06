//
//  ViewController.swift
//  AssignmentTwo
//
//  Created by Jahan on 07/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Property
    
    var allArtworks = [Artwork]()
    // CD = Core data
    var artworksCD = [ArtworkCore]()
    var artworksCDDict: [String:[ArtworkCore]]!
    var artworkLocationNotesCD = [String]()
    
    // Used to filter the search results. i.e. the section and artwork title
    var searchArtworkSection = [String]()
    var searchArtworkTitle = [String]()
    var artworkTitles = [String]()
    
    var searching = false
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    let cache = NSCache<NSString, NSData>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        PersistenceService.clearCoreData()
        decodeJson()
        
        table.reloadData()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

// MARK: - Map

extension ViewController {
    // Setting the current location to the ashton building, & the zoom of the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0]
        let lat = locationOfUser.coordinate.latitude
        let long = locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.004
        let lonDelta: CLLocationDegrees = 0.004
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotationsSection() {
        artworksCD.count == 0 ? add(arrCount: allArtworks.count) : add(arrCount: artworksCD.count)
    }
    
    func add(arrCount: Int) {
        for i in 0..<arrCount {
            
            let annotation = MKPointAnnotation()
            annotation.title = allArtworks[i].locationNotes
            
            let artwork = artworksCDDict[annotation.title!]?.first
            annotation.coordinate = CLLocationCoordinate2D(latitude: artwork!.lat, longitude: artwork!.long)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print("hello!")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BuildingArtworksController") as! BuildingArtworksController
        
        if let buildingArtworks = view.annotation?.title {
            print("Sending:")
            print((artworksCDDict?[buildingArtworks!])!)
            vc.artworks = (artworksCDDict?[buildingArtworks!])!
            vc.buildingArtworks = buildingArtworks!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - TableView

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        if (searching && searchArtworkSection.count != 0) {
            for x in 0..<searchArtworkTitle.count {
                for y in 0..<artworksCD.count {
                    
                    if (searchArtworkSection[x] == artworksCD[y].locationNotes) {
                        return (searchArtworkSection[x].isEmpty) ? ("searching") : (searchArtworkSection[x])
                    }
                }
            }
        }
        return artworkLocationNotesCD[section]
    }
    
    // returns the range of years,  so from from 2001 - 2018 (Returns 18 sections)
    func numberOfSections(in tableView: UITableView) -> Int {
        return (searching) ? searchArtworkTitle.count : artworkLocationNotesCD.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searching) ? searchArtworkTitle.count : artworksCDDict[artworkLocationNotesCD[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jsonCells", for: indexPath)
        
        var titleCount = 0
        // If searching then store the amount of searches found at first
        if (searching && searchArtworkTitle.count > 1) {
            titleCount = searchArtworkTitle.count

            for x in 0..<searchArtworkTitle.count {
                for y in 0..<artworksCD.count {
                    
                    if (searchArtworkTitle[x] == artworksCD[y].title!) { // Searching title matches a title from the array
                        
                        cell.textLabel?.text = artworksCD[y].title
                        cell.detailTextLabel?.text = artworksCD[y].artist
                        
                        if !(searchArtworkSection.contains(artworksCD[y].locationNotes!)) { // If we already have the section then dont append
                            searchArtworkSection.append(artworksCD[y].locationNotes!)
                        }
                        // If the search of artworks has become shorter than the original search, than we reinit the search array with updated searches
                        if (searchArtworkSection.count != titleCount) {
                            searchArtworkSection.removeAll()
                            if (searchArtworkTitle[x] == artworksCD[y].title!) { // Searching title matches a title from the array
                                searchArtworkSection.append(artworksCD[y].locationNotes!) // Adding new titles from searches to the array
                            }
                        }
                    }
                }
            }
        }
        else  {
            
            let artwork = artworksCDDict[artworkLocationNotesCD[indexPath.section]]![indexPath.row]
            cell.textLabel?.text = artwork.title
            cell.detailTextLabel?.text = artwork.artist
        }
        
        return cell
    }
    
    
    // Passes the selected section and row to the second screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let arrayIndexRow = table.indexPathForSelectedRow?.row
        let arrayIndexSection = table.indexPathForSelectedRow?.section
        let selectedCell = artworksCDDict[artworkLocationNotesCD[arrayIndexSection!]]![arrayIndexRow!]
        
        if let secondClass = segue.destination as? DetailViewController {
            secondClass.desArtworkDetail = selectedCell
            secondClass.cache = cache // Sending the cache image
        }
            
        else if let buildingArtworks = segue.destination as? BuildingArtworksController {
            
        }
        
        table.deselectRow(at: table.indexPathForSelectedRow!, animated: true) // Little animation touches
    }
}



extension ViewController {
    func decodeJson() { // Importing the JSON and storing it into an array
        
        var fileNames = [String]()
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campus_artworks&lastUpdate=2017-11-01") {
            let session = URLSession.shared
            
            session.dataTask(with: url) { (data, response, err) in
                
                guard let jsonData = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let getArtworks = try decoder.decode(AllArtworks.self, from: jsonData)
                    self.allArtworks = getArtworks.campus_artworks
                    
                    for i in 0..<self.allArtworks.count {
                        
                        self.artworkTitles.append(self.allArtworks[i].title!) // Used to filter the search titles
                        fileNames.append(self.allArtworks[i].fileName!) // used to find the image from URL
                        
                        // Check if the JSON has new files or if it is already stored in core data:
                        if (PersistenceService.checkCoreData(aReportTitle: self.allArtworks[i].title!)){
                            //                            print("Already in core data: dont need to save again")
                        }
                            
                        else {
                            //                            print("Adding new artwork")
                            let artworkCore = ArtworkCore(context: PersistenceService.context)
                            artworkCore.title = self.allArtworks[i].title!
                            artworkCore.artist = self.allArtworks[i].artist!
                            artworkCore.information = self.allArtworks[i].Information!
                            artworkCore.yearOfWork = self.allArtworks[i].yearOfWork!
                            artworkCore.locationNotes = self.allArtworks[i].locationNotes!
                            artworkCore.fileName = self.allArtworks[i].fileName!
                            
                            artworkCore.lat = Double(self.allArtworks[i].lat)!
                            artworkCore.long = Double(self.allArtworks[i].long)!
                            
                            PersistenceService.saveContext()
                        }
                    }
                    print("all artworks count \(self.allArtworks.count)")
                    
                    print("Loading tableview from Core data")
                    self.fetchCoreData()
                    
                    DispatchQueue.main.async(execute: {
                        self.addAnnotationsSection()
                        self.table.reloadData()
                    })
                    
                    self.cacheAllImages(fileNames: fileNames)
                }
                    
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                }
                .resume()
            
        }
    }
    
    
    func fetchCoreData() {
        
        let fetchRequest: NSFetchRequest<ArtworkCore> = ArtworkCore.fetchRequest()
        do {
            
            let currentLat = Double((self.locationManager.location?.coordinate.latitude)!)
            let currentLong = Double((self.locationManager.location?.coordinate.longitude)!)
            let current = currentLat + currentLong
            
            // print("coredata count: \(self.artworksCD.count)")
            // print("current location is: \(current)")
            
            
            artworksCD = try PersistenceService.context.fetch(fetchRequest)
            
            //            Sorting the core data artwork array based on distance from current location
            artworksCD = artworksCD.sorted(by: {
                (Double($0.lat) - Double($0.long)).distance(to: current) < (Double($1.lat) - Double($1.long)).distance(to: current)
            })
            
            for i in 0..<artworksCD.count {
                if !(artworkLocationNotesCD.contains(artworksCD[i].locationNotes!)) {
                    artworkLocationNotesCD.append(artworksCD[i].locationNotes!)
                }
            }
            artworksCDDict = Dictionary(grouping: artworksCD, by: { $0.locationNotes! })
            
            for i in 0..<artworkLocationNotesCD.count {
                print("\(i) + \(artworkLocationNotesCD[i])")
            }
        }
            
        catch {
            print("error")
        }
    }
    
    func download(fileName: String) {
        let session = URLSession.shared
        
        let baseUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/"
        
        var url = URL(string: baseUrl)!
        url.appendPathComponent(fileName)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            //print("\(Date()) \(fileName)")
            
            self?.cache.setObject(data! as NSData, forKey: fileName as NSString)
        }
        
        task.resume()
    }
    
    func cacheAllImages(fileNames: [String]) {
        let queue = OperationQueue.main
        queue.maxConcurrentOperationCount = 3
        
        for i in 0..<fileNames.count {
            queue.addOperation {
                self.download(fileName: fileNames[i])
            }
        }
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchBar.text?.isEmpty == true) {
            searching = false
            searchArtworkTitle.removeAll()
            searchArtworkSection.removeAll()
            table.reloadData()
        }
        else {// The user is writting the name of the artwork, with this I need to find the locationNote of that artwork and make that the section title
            searchArtworkTitle = artworkTitles.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
            searching = true
            table.reloadData()
        }
    }
    
}


//            self.artworksCD = artworksCD.sorted(by: {
//                (Double($0.lat) + Double($0.long)).distance(to: current) < (Double($1.lat) + Double($1.long)).distance(to: current)
//            })

//func mapView(_ map: MKMapView, didSelect view: MKAnnotationView) {
//    print("hello!")
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let vc = storyboard.instantiateViewController(withIdentifier: "BuildingArtworksController") as! BuildingArtworksController
//
//    if let building = view.annotation?.title {
//        print("hellonidjnsaidansdouas!")
//        print("Sending:")
//        print((artworksCDDict?[building!])!)
//        vc.artworks = (artworksCDDict?[building!])!
//        vc.building = building!
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}

//            artworksCD = artworksCD.sorted(by: {
//                (Double($0.lat) - Double($0.long)) - current < (Double($1.lat) - Double($1.long)) - current})
//            artworksCD.reverse()
