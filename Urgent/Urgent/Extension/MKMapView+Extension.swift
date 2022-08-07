//
//  MKMapView+Extension.swift
//  Urgent
//
//  Created by jang gukjin on 2022/08/07.
//  Copyright © 2022 jang gukjin. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func annotationView(selection: ViewController.Selection, annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        switch selection {
        case .count:
            let annotationView = self.annotationView(of: CountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.backgroundColor = .urgent
            return annotationView
        case .image:
            let annotationView = self.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.image = .pin
            return annotationView
        }
    }
    
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
}
