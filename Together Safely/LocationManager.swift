//
//  LocationManager.swift
//  Together Safely
//
//  Created by Larry Shannon on 7/25/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    let manager = CLLocationManager()
    let db =  CoreDataManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    @Published var alert: Bool = false
    @Published var alert2: Bool = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.startUpdatingLocation()
    }
    
    func checkIfEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("Location service denied")
                case .authorizedAlways, .authorizedWhenInUse:
                    return
                @unknown default:
                break
            }
        }
        print("Location services are not enabled")
        if !alert2 {
            alert2 = true
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            print("\n\nLocation update called\n\n")
            lastKnownLocation = location
//            db.saveDataPoints(timeStamp: Date(), lat: location.latitude, lng: location.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied {
            if !alert {
                alert = true
            }
        }
        else {
            manager.startUpdatingLocation()
        }
    }
}

extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
