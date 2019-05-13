//
//  MapViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 5.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    // You don't need to modify the default init(nibName:bundle:) method.
    
    private let markerTitle: String
    private let location: Location
    
    init(markerTitle: String, location: Location) {
        self.markerTitle = markerTitle
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.mapType = .hybrid
        mapView.settings.indoorPicker = true
        mapView.settings.myLocationButton = false
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        title = markerTitle
        marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        marker.title = markerTitle
        marker.map = mapView
    }
}
