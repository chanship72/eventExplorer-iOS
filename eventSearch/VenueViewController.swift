//
//  VenueViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/18/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import Alamofire_SwiftyJSON

class VenueViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressText: UITextView!
    @IBOutlet weak var venueInfoView: UIView!
    @IBOutlet weak var cityText: UITextView!
    @IBOutlet weak var phoneText: UITextView!
    @IBOutlet weak var openText: UITextView!
    @IBOutlet weak var generalText: UITextView!
    @IBOutlet weak var childView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let detailCtr = self.tabBarController as! DetailViewController
        
        self.addressText.text = detailCtr.detail.venueInfo?.address
        self.cityText.text = detailCtr.detail.venueInfo?.city
        self.phoneText.text = detailCtr.detail.venueInfo?.phoneNumber
        self.openText.text = detailCtr.detail.venueInfo?.openHours
        self.generalText.text = detailCtr.detail.venueInfo?.generalRules
        self.childView.text = detailCtr.detail.venueInfo?.childRules
        
        initMap()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func initMap(){
        mapView.clear()
        let detailCtr = self.tabBarController as! DetailViewController
        // create map
        
        let lat = detailCtr.detail.venueInfo!.venueLocation!.latitude
        let lon = detailCtr.detail.venueInfo!.venueLocation!.longitude
        mapView.camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 12.0)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.map = mapView
    }
}
extension VenueViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
