//
//  LocationManagerDelegate.swift
//  HelloLocationSwiftUI
//
//  Created by 申潤五 on 2024/9/26.
//

import UIKit
import CoreLocation

class LocationDelegate: NSObject,ObservableObject {
    @Published var location: CLLocation? = nil
}

extension LocationDelegate:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last
        print(locations.last?.coordinate)
    }
}
