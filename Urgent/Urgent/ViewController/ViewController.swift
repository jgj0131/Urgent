//
//  ViewController.swift
//  Urgent
//
//  Created by jang gukjin on 09/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps

enum GPSState {
    case on
    case off
}

var gpsState: GPSState = .on

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
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    var latitudeAndLongitude: String?
    var secondTimer: Timer?
    var number = 0.0
    
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
    var settingButtonUpAndDown = false
    
    //let cardHeight:CGFloat = self.view
    let cardHandleAreaHeight:CGFloat = 65
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    var settingButtonConstraint: NSLayoutConstraint!
    
    var messageSendOrNot: MessageState = .notSend
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    enum MessageState {
        case send
        case notSend
    }
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    // MARK: LifeCyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingButtonConstraint = settingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -105)
        settingButtonConstraint.isActive = true
        settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.7).isActive = true
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
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
            if datum["위도"] != "", datum["경도"] != "", datum["소재지도로명주소"] != nil {
                let data = datum
                let item =
                    POIItem(position: CLLocationCoordinate2DMake(Double(datum["위도"] ?? "0.00") ?? 0.00, Double(datum["경도"] ?? "0.00") ?? 0), data: data)
                clusterManager.add(item)
            }
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
                                                     zoom: mapView.camera.zoom)
            
//            marker.title = poiItem.data["화장실명"]
//            marker.snippet = poiItem.data["개방시간"] == "" ? "정보없음" : poiItem.data["개방시간"]! + "\n장애인용(남: \(Int(poiItem.data["남성용-장애인용대변기수"] ?? "0") ?? 0 > 0 ? "Y" : "N"), 여: \(Int(poiItem.data["여성용-장애인용대변기수"] ?? "0") ?? 0 > 0 ? "Y" : "N"))"
            marker.icon = UIImage(named: "marker_black")
            marker.tracksInfoWindowChanges = true
            let restroomDatas: [String:String] = poiItem.data
            dataDelegate?.sendData(data: restroomDatas)
            dismiss(animated: true, completion: nil)
            cardViewController.output(data:restroomDatas)
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 185, right: 0)
            settingButton.translatesAutoresizingMaskIntoConstraints = false
            settingButtonConstraint.constant = -290
            settingButtonUpAndDown = true
            NSLog("Did tap marker for cluster item \(poiItem.data)")
        } else {
            NSLog("Did tap a normal marker")
        }
        messageSendOrNot = .send
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        marker.icon = UIImage(named: "marker_white")
    }
    
    /// mapView를 터치했을 때 동작하는 메소드
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        cardViewController.view.removeFromSuperview()
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        settingButtonConstraint.constant = -105
        settingButtonUpAndDown = false
    }
    
    /// infoWindow를 커스터마이징 하는 메소드
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 70))
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 31.0/255.0, green: 76.0/255.0, blue: 124.0/255.0, alpha: 1.0).cgColor
        if let poiItem = marker.userData as? POIItem {
            let toiletTitle = UILabel(frame: CGRect.init(x: 8, y: 8, width: 10, height: 15))
            toiletTitle.text = poiItem.data["화장실명"]
            toiletTitle.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
            toiletTitle.sizeToFit()
            view.addSubview(toiletTitle)

            let toiletSnippet = UILabel(frame: CGRect.init(x: toiletTitle.frame.origin.x, y: toiletTitle.frame.origin.y + toiletTitle.frame.size.height + 2, width: 50, height: 15))
            toiletSnippet.text = poiItem.data["개방시간"] == "" ? "정보없음" : poiItem.data["개방시간"]!
            toiletSnippet.font = UIFont.systemFont(ofSize: 12, weight: .light)
            toiletSnippet.textColor = .gray
            toiletSnippet.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
            toiletSnippet.sizeToFit()
            view.addSubview(toiletSnippet)
            
            let toiletYesNo = UILabel(frame: CGRect.init(x: toiletTitle.frame.origin.x, y: toiletSnippet.frame.origin.y + toiletSnippet.frame.size.height + 1, width: 50, height: 15))
                        toiletYesNo.text = "장애인용(남: \(Int(poiItem.data["남성용-장애인용대변기수"] ?? "0") ?? 0 > 0 ? "Y" : "N"), 여: \(Int(poiItem.data["여성용-장애인용대변기수"] ?? "0") ?? 0 > 0 ? "Y" : "N"))"
            toiletYesNo.font = UIFont.systemFont(ofSize: 12, weight: .light)
            toiletYesNo.textColor = .gray
            toiletYesNo.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
            toiletYesNo.sizeToFit()
            view.addSubview(toiletYesNo)
                        
            if toiletTitle.frame.width > toiletSnippet.frame.width, toiletTitle.frame.width > toiletYesNo.frame.width {
                view.frame.size.width = toiletTitle.frame.size.width + 16
            } else if toiletSnippet.frame.width > toiletYesNo.frame.width{
                view.frame.size.width = toiletSnippet.frame.size.width + 16
            } else {
                view.frame.size.width = toiletYesNo.frame.size.width + 16
            }
        }
        return view
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
        cardViewController.view.layer.cornerRadius = 15//cardViewController.view.frame.height/40
        
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
    
    @objc
    func timeCallback() {
        number += 1
        print("GPS 탐지 시간: \(number)")
        if number == 120 {
            notificateGPSStillWork()
        }
    }
    
    func notificateGPSStillWork() {
        let content = UNMutableNotificationContent()
        content.title = "GPS가 켜져있습니다."
        content.body = "30분 이상 GPS가 켜져있습니다. 위험대비 문자를 보낸 것이 아니라면 전력 소모를 줄이기 위해 앱을 종료해주세요."
        
        let TimeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(String(describing: index))timerdone", content: content, trigger: TimeIntervalTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
    func timerMeasurementsInBackground() {
        if number < 120, number >= 0 {
            if let timer = secondTimer {
                if !timer.isValid {
                    secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCallback), userInfo: nil, repeats: true)
                    RunLoop.current.add(secondTimer!, forMode: .common)
                }
            } else {
                secondTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCallback), userInfo: nil, repeats: true)
                RunLoop.current.add(secondTimer!, forMode: .common)
            }
        } else {
            if let timer = secondTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            number = -1
        }
    }
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
                   return
               }
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: mapView.camera.zoom )
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        if UIApplication.shared.applicationState == .active {
            
        } else {
            print("위도:\(location.coordinate.latitude), 경도: \(location.coordinate.longitude)")
            timerMeasurementsInBackground()
        }
        if gpsState == .off {
            locationManager.stopUpdatingLocation()
            gpsState = .on
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

extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        self.present(settingsViewController, animated: true, completion: nil)
    }
}
