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

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var data: [String:String]
    
    init(position: CLLocationCoordinate2D, data: [String:String]) {
        self.position = position
        self.data = data
    }
}

class ViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    // MARK: IBOutlet
    @IBOutlet weak var settingButton: UIButton!
    
    // MARK: Property
    var originY: CGFloat?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    let restroomData = RestroomDataSource()
    var dataDelegate: SendDataDelegate?
    
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    
    //let cardHeight:CGFloat = self.view
    let cardHandleAreaHeight:CGFloat = 65
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    // MARK: LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
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
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        mapView.addSubview(settingButton)
        mapView.isHidden = true
        originY = mapView.frame.origin.y

        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        
        for datum in restroomData.getDataForFata() {
            let data = datum
            let item =
                POIItem(position: CLLocationCoordinate2DMake(Double(datum["위도"] ?? "0.00") ?? 0.00, Double(datum["경도"] ?? "0.00") ?? 0), data: data)
            clusterManager.add(item)
        }
        clusterManager.cluster()
        clusterManager.setDelegate(self, mapDelegate: self)
        
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.removeFromSuperview()
    }
    
    // MARK: Custom Method
    /// marker를 터치했을 때 동작하는 메소드
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            if cardViewController.isViewLoaded {
                cardViewController.view.removeFromSuperview()
            }
            setupCard()
            mapView.selectedMarker = marker
            mapView.camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude,
                                                     longitude: marker.position.longitude,
                                                     zoom: zoomLevel)
            marker.title = poiItem.data["화장실명"]
            marker.snippet = poiItem.data["구분"]
            marker.userData = poiItem.data
            let restroomDatas: [String:String] = marker.userData as? [String:String] ?? ["":""]
            dataDelegate?.sendData(data: restroomDatas)
            dismiss(animated: true, completion: nil)
            cardViewController.output(data:restroomDatas)
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 185, right: 0)
            NSLog("Did tap marker for cluster item \(poiItem.data)")
        } else {
            NSLog("Did tap a normal marker")
        }
        return true
    }
    
    /// mapView를 터치했을 때 동작하는 메소드
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        cardViewController.view.removeFromSuperview()
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    /// CardView를 setUp하는 메소드
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - (cardHandleAreaHeight * 3), width: self.view.bounds.width, height: self.view.bounds.height * 0.8)
        
        cardViewController.view.clipsToBounds = true
        cardViewController.view.layer.cornerRadius = cardViewController.view.frame.height/40
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))

        cardViewController.backgroundArea.addGestureRecognizer(panGestureRecognizer)
        visualEffectView.removeFromSuperview()
        hiddenTitle(true)
    }
    
    /// Pan했을 때의 동작을 나타내는 메소드
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.cardViewController.handleArea)
        var fractionComplete = (translation.y * 1.8) / self.view.bounds.height * 0.8//cardHeight
        fractionComplete = cardVisible ? fractionComplete : -fractionComplete
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            if fractionComplete > 0 {
                updateInteractiveTransition(fractionCompleted: fractionComplete)
            }
        case .ended:
            continueInteractiveTransition()
            if fractionComplete > 0, fractionComplete < 0.3 {
                animateTransitionIfNeeded(state: nextState, duration: 0.9)
            }
            if cardVisible == true {
                hiddenTitle(true)
            }
        default:
            break
        }
    }
    
    /// CardVisible의 유무에 따라 Label들을 숨길지 표시할지 정하는 메소드
    func hiddenTitle(_ bool: Bool) {
        for title in self.cardViewController.titles {
            title.isHidden = bool
        }
        self.cardViewController.publicManAndWoman.isHidden = bool
        self.cardViewController.openingTime.isHidden = bool
        self.cardViewController.manToiletCount.isHidden = bool
        self.cardViewController.disabledManToiletCount.isHidden = bool
        self.cardViewController.womanToiletCount.isHidden = bool
        self.cardViewController.disabledWomanToiletCount.isHidden = bool
    }
    
    /// cardView가 올라온 상태와 내려가있을 떄의 높이를 설정하고, 애니메이션을 시작하는 메소드
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.view.bounds.height * 0.8)//self.cardHeight
                    self.hiddenTitle(false)
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHandleAreaHeight * 3)
                    for title in self.cardViewController.titles {
                        title.isHidden = false
                    }
                    self.hiddenTitle(false)
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }

            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    /// 애니메이션 배열이 비어있다면 채워넣고 현재 실행중인 애니메이션을 중지하는 메소드
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    /// 이동한 거리만큼 화면을 업데이트하는 메소드
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    /// 일시 중지된 애미메이션의 최종 타이밍 및 지속 시간을 조정하는 메소드
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }

    /// clustering된 item을 탭할때 해당 item을 기준으로 화면을 이동하고 줌하는 메소드
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
}

// MARK: Extension
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
