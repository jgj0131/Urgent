//
//  ViewController.swift
//  Urgent
//
//  Created by jang gukjin on 09/08/2019.
//  Copyright © 2019 jang gukjin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
//import GooglePlaces
//import GoogleMaps
import GoogleMobileAds
import Cluster
import Lottie
import MessageUI

enum GPSState {
    case on
    case off
}

var gpsState: GPSState = .on
var height: CGFloat = 0.0

public struct POIItem {
    //  MARK: Properties
    public let data: [String: String]
    ///    The current location of the rapper.
    public let coordinate: CLLocationCoordinate2D
}

class ViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate, GADBannerViewDelegate {
    // MARK: IBOutlet
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dateInfoView: UILabel!
    
    // MARK: Google Mobile Ads
    private var bannerView: GADBannerView!

    // MARK: Property
    let animationView: AnimationView = .init(name: "complete")
    lazy var clusterManager: ClusterManager = { [unowned self] in
        let manager = ClusterManager()
        manager.delegate = self
        manager.maxZoomLevel = 17
        manager.minCountForClustering = 3
        manager.clusterPosition = .nearCenter
        return manager
    }()
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    private var latitudeAndLongitude: String?
    private var secondTimer: Timer?
    private var number = 0.0
    
    private var originY: CGFloat?
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var zoomLevel: Float = 15.0
    let restroomData = RestroomDataSource()
    private var dataDelegate: SendDataDelegate?
    var destination: MKMapItem?
    
    private var cardViewController:CardViewController!
    private var visualEffectView:UIVisualEffectView!
    private var settingButtonUpAndDown = false
    
    private let cardHandleAreaHeight:CGFloat = 65
    
    private var cardVisible = false
    private var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted:CGFloat = 0
    
    private var settingButtonConstraint: NSLayoutConstraint!
    
    private var messageSendOrNot: MessageState = .notSend
    
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
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "useButtonTitle")
        if launchedBefore {
            
        } else {
            UserDefaults.standard.set("위험대비문자 발송", forKey: "useButtonTitle")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCompleteButton), name: NSNotification.Name("sendMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playAnimation), name: NSNotification.Name("playAnimation"), object: nil)
        
        let tapAnimationView: UITapGestureRecognizer = .init(target: self, action: #selector(sendCompleteButton))
        animationView.addGestureRecognizer(tapAnimationView)
        animationView.frame = CGRect(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height / 2, width: 90, height: 90)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        if UserDefaults.standard.bool(forKey: "sentHelpMessage") {
            if !mapView.subviews.contains(animationView) {
                mapView.addSubview(animationView)
                animationView.play()
            }
        }
        
        
        dateInfoView.layer.cornerRadius = 5
        dateInfoView.clipsToBounds = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.dateInfoView.removeFromSuperview()
        })
        
        myLocationButton.layer.cornerRadius = 15
        myLocationButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        myLocationButton.addTarget(self, action: #selector(findMyLocation), for: .touchUpInside)
        myLocationButton.layer.shadowColor = UIColor.black.cgColor
        myLocationButton.layer.shadowOpacity = 0.25
        myLocationButton.layer.shadowOffset = .zero
        myLocationButton.layer.shadowRadius = 3
        myLocationButton.layer.shadowPath = nil
        
        settingButton.layer.cornerRadius = 15
        settingButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        settingButton.layer.shadowColor = UIColor.black.cgColor
        settingButton.layer.shadowOpacity = 0.25
        settingButton.layer.shadowOffset = .zero
        settingButton.layer.shadowRadius = 3
        settingButton.layer.shadowPath = nil
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        mapView.delegate = self
        mapView.showsUserLocation = true
//        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        mapView.setUserTrackingMode(.follow, animated: true)
        
        setCompass()
        setMapView()
        
        cardViewController = CardViewController(nibName:"CardViewController", bundle:nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        cardViewController.view.removeFromSuperview()

        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)

        self.bannerView.delegate = self
        
        self.bannerView.adUnitID = googleAdUnitID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        addBannerViewToView(bannerView)
    }

    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
    }
    
    func setCompass() {
        let compass = MKCompassButton(mapView: mapView)
        compass.frame.origin = CGPoint(x: UIScreen.main.bounds.width - compass.frame.width - 10, y: myLocationButton.frame.maxY + 10)
        compass.compassVisibility = .visible
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCompass(_ :)))
        compass.addGestureRecognizer(tapGestureRecognizer)
        view.addSubview(compass)
    }
    
    @objc
    func tapCompass(_ sender: MKCompassButton) {
        if mapView.userTrackingMode == .followWithHeading {
            mapView.setUserTrackingMode(.follow, animated: true)
        } else {
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }
    }
    
    @objc
    func setCompleteButton(_ notification: Notification) {
        if let showAnimationView = notification.object as? Bool, showAnimationView == true {
            if !mapView.subviews.contains(animationView) {
                mapView.addSubview(animationView)
                animationView.play()
            }
        } else {
            animationView.removeFromSuperview()
        }
        animateTransitionIfNeeded(state: .collapsed, duration: 0.9)
    }
    
    @objc
    func playAnimation(_ notification: Notification) {
        animationView.play()
    }

    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.topAnchor.constraint(equalTo: bannerView.topAnchor)
        ])
    }

    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide.bottomAnchor, attribute: .top, multiplier: 1, constant: 0))
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
    }
    
    // MARK: Custom Method
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
       
        let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleCardSwipeUp(recognizer:)))
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleCardSwipeDown(recognizer:)))
        
        upSwipeGestureRecognizer.direction = .up
        downSwipeGestureRecognizer.direction = .down

        cardViewController.backgroundArea.addGestureRecognizer(upSwipeGestureRecognizer)
        
        cardViewController.backgroundArea.addGestureRecognizer(downSwipeGestureRecognizer)
        
        visualEffectView.removeFromSuperview()
        hiddenTitle(true)
    }
    
    /// GPS가 켜져있다는 푸시 알림을 보내는 메소드
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
        self.cardViewController.womanToiletCount.isHidden = bool
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
                    self.hiddenTitle(true)
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
    
    // MARK: Gesture
    /// Tap 했을 때 동작을 나타내는 메소드
    @objc
    func handleCardTap(recognzier: UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    /// Swipe  Up했을 때 동작을 나타내는 메소드
    @objc
    func handleCardSwipeUp(recognizer: UISwipeGestureRecognizer) {
        if nextState == .expanded {
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        }
    }
    
    /// Swipe  Down했을 때 동작을 나타내는 메소드
    @objc
    func handleCardSwipeDown(recognizer: UISwipeGestureRecognizer) {
        if nextState == .collapsed {
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        }
    }

    /// 시간을 체크하여 30분이 되면 푸시알림을 보내는 메소드
    @objc
    func timeCallback() {
        number += 1
        print("GPS 탐지 시간: \(number)")
        if number == 1800 {
            notificateGPSStillWork()
        }
    }
    
    /// 내 위치로 이동합니다.
    @objc
    func findMyLocation() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    /// 완료 메세지를 보냅니다.
    @objc
    func sendCompleteButton() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
        guard MFMessageComposeViewController.canSendText() else {
            print("메세지를 보낼 수 없습니다.")
            return
        }
    
        let savedContacts = UserDefaults.standard.object(forKey: "Contacts") as? [[String : String]] ?? [[String:String]]()
        let userContacts = savedContacts.map() { $0["phone"]! }
        let onOffStatus = UserDefaults.standard.bool(forKey: "OnOffSwitch")
        let timerText = (Int(timerData) / 3600 == 0 ? "" : "\(Int(timerData) / 3600) 시간 ") + "\((Int(timerData) % 3600) / 60)분"
    
        let messageViewController = MFMessageComposeViewController()
        messageViewController.messageComposeDelegate = self
        messageViewController.recipients = userContacts
        
        if userContacts.count >= 1, onOffStatus == true {
            messageViewController.body = """
            [급해(App)]
            무사히 용무를 마쳤습니다. 걱정 안 하셔도 됩니다.
            감사합니다.
            """
            
            present(messageViewController, animated: true, completion: nil)
        }
    }
}

// MARK: Extension - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func timerMeasurementsInBackground() {
        if number < 1800, number >= 0 {
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
                   return
               }
        print("Location: \(location)")
        
        if UIApplication.shared.applicationState == .active {
            if let timer = secondTimer {
                if timer.isValid {
                    timer.invalidate()
                }
            }
            number = 0
            print("시간 멈춤")
        } else if UIApplication.shared.applicationState == .background{
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
//            mapView.isHidden = false
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            print("Not Found Location")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    /// MapView에 화장실 마커를 남깁니다.
    func setMapView(){
        let annotations: [CustomAnnotation] = self.restroomData.getDataForFata().map { datum in
            if datum["위도"] != "", datum["경도"] != "", datum["소재지도로명주소"] != nil {
                let data = datum
                let item = POIItem(data: data, coordinate: CLLocationCoordinate2DMake(Double(datum["위도"] ?? "0.00") ?? 0.00, Double(datum["경도"] ?? "0.00") ?? 0))
                let annotation = CustomAnnotation()
                annotation.coordinate = item.coordinate
                annotation.title = data["소재지도로명주소"] ?? ""
                annotation.data = data
                return annotation
            } else {
                return CustomAnnotation()
            }
        }
            
        clusterManager.add(annotations)
        clusterManager.reload(mapView: mapView)
    }
    
    func setMarker(coordinate: CLLocationCoordinate2D, data: [String: String]) {
        let annotation = CustomAnnotation()
        
        annotation.coordinate = coordinate
        annotation.title = data["소재지도로명주소"] ?? ""
        annotation.data = data
        self.mapView.addAnnotation(annotation)
        self.findAddr(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    /// 위도, 경도로 주소를 찾습니다.
    func findAddr(lat: CLLocationDegrees, long: CLLocationDegrees){
        let findLocation = CLLocation(latitude: lat, longitude: long)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                var myAdd: String = ""
                if let area: String = address.last?.locality{
                    myAdd += area
                }
                if let name: String = address.last?.name {
                    myAdd += " "
                    myAdd += name
                }
            }
        })
    }
}

// MARK: Extension - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView: mapView) { finished in
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        self.mapView.removeOverlays(self.mapView.overlays)
//        cardViewController.view.removeFromSuperview()
//        print("사라짐")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else { return }
        
        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
        } else {
            self.mapView.removeOverlays(self.mapView.overlays)
            
            guard let customAnnotation = annotation as? CustomAnnotation else {
                return
            }
            
            getDirections(annotation: customAnnotation)
            
            if cardViewController.isViewLoaded {
                cardViewController.view.removeFromSuperview()
            }
            setupCard()
            
            let restroomDatas: [String:String] = customAnnotation.data ?? [:]
            dataDelegate?.sendData(data: restroomDatas)
            cardViewController.output(data:restroomDatas)
            messageSendOrNot = .send
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            let identifier = "cluster"
            let selection = Selection(rawValue: 0)!
            return mapView.annotationView(selection: selection, annotation: annotation, reuseIdentifier: identifier)
        } else {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            if annotation.title == "My Location" {
                return nil
            } else {
                annotationView.glyphImage = UIImage(systemName: "pin")//"sun.max.fill")
                annotationView.markerTintColor = .urgent
                return annotationView
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .path
        renderer.lineWidth = 7
        return renderer
    }
    
    func getDirections(annotation: CustomAnnotation) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination =  MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: {( response: MKDirections.Response!, error: Error!) in
            if error != nil {
                print("Error getting directions")
            } else {
                self.showRoute(response: response)
            }
        })
    }
    
    // 경로에 대한 도형을 맵 뷰 위에 추가하고 턴바이턴 경로를 콘솔에 출력
    func showRoute(response: MKDirections.Response) {
        // MKRoute 객체들을 반복해서 가져와서 맵 뷰의 레이어로 polyline을 추가한다.
        for route in response.routes as [MKRoute] {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            // 턴바이턴 경로 출력(경로의 각 구간에 대한 텍스트 안내)
            for step in route.steps {
                print(step.instructions)
            }
        }
        
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegion(center: userLocation.location!.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
        mapView.setRegion(region, animated: true)
    }
}

// MARK: Extension - UNUserNotificationCenterDelegate
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        self.present(settingsViewController, animated: true, completion: nil)
    }
}

// MARK: Extension - ClusterManagerDelegate
extension ViewController: ClusterManagerDelegate {
    func cellSize(for zoomLevel: Double) -> Double? {
        return nil // default
    }
        
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return !(annotation is Annotation)
    }
}

extension ViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("cancelled")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("sent message:", controller.body ?? "")
            NotificationCenter.default.post(name: NSNotification.Name("sendMessage"), object: false)
            UserDefaults.standard.set(false, forKey: "sentHelpMessage")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("failed")
            dismiss(animated: true, completion: nil)
        @unknown default:
            print("unkown Error")
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Extension - Self
extension ViewController {
    enum Selection: Int {
        case count, image
    }
}
