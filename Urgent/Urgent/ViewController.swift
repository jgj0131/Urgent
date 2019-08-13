//
//  ViewController.swift
//  Urgent
//
//  Created by jang gukjin on 09/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {
    // MARK: IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: Property
    var originY: CGFloat?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    let restroomData = RestroomDataSource()
    
    // MARK: LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isHidden = true

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86,
                                              longitude: 151.20,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        //mapView.settings.compassButton = true
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        mapView.isHidden = true
        
        originY = mapView.frame.origin.y

        for datum in restroomData.getDataForFata(data: "명사십리") {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(datum["위도"] ?? "0.00") ?? 0.00, longitude: Double(datum["경도"] ?? "0.00") ?? 0)
            marker.title = datum["화장실명"]
            marker.snippet = datum["구분"]
            marker.userData = datum
            marker.map = mapView
        }
    }
    
    // MARK: Custom Method
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        scrollView.isHidden = false
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            if self.originY == nil { self.originY = mapView.frame.origin.y }
            mapView.frame.origin.y = self.originY! - self.scrollView.frame.height
        })
        print(marker.title)
        let restroomData = marker.userData as! [String:String]
        print(restroomData["소재지지번주소"] == nil ? "정보없음" : restroomData["소재지지번주소"]!)
        print(restroomData["남여공용화장실여부"] == nil ? "정보없음" : restroomData["남여공용화장실여부"]!)
        print(restroomData["개방시간"] == nil ? "정보없음" : restroomData["개방시간"]!)
        print(restroomData["남성용-대변기수"] == nil ? "정보없음" : restroomData["남성용-대변기수"]!)
        print(restroomData["남성용-장애인용대변기수"] == nil ? "정보없음" :  restroomData["남성용-장애인용대변기수"]!)
        print(restroomData["여성용-대변기수"] == nil ? "정보없음" : restroomData["여성용-대변기수"]!)
        print(restroomData["여성용-장애인용대변기수"] == nil ? "정보없음" : restroomData["여성용-장애인용대변기수"]!)
        
        return true
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            guard let originY = self.originY else { return }
            mapView.frame.origin.y = self.originY!
        })
        print("창 눌렀당")
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
