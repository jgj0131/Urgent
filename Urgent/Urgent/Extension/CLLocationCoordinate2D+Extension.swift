//
//  CLLocationCoordinate2D+Extension.swift
//  Urgent
//
//  Created by jang gukjin on 2022/08/10.
//  Copyright © 2022 jang gukjin. All rights reserved.
//

import Foundation

extension CLLocationCoordinate2D {
    /// Returns distance from coordianate in meters.
    /// - Parameter from: coordinate which will be used as end point.
    /// - Returns: Returns distance in meters.
    func getDistance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
