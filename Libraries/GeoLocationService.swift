//
//  GeolocationService.swift
//  Pickup
//
//  Created by MECHIN on 8/11/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import Foundation
import CoreLocation

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

class GeoLocationService {
    
    static let instance = GeoLocationService()

    private (set) var authorizedStatus: Driver<CLAuthorizationStatus>
    
    private let locationManager = CLLocationManager()
    let location = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    let disposeBag = DisposeBag()

    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        authorizedStatus = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            
            return locationManager
                .rx
                .didChangeAuthorizationStatus
                .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> Driver<CLLocationCoordinate2D> {
        
        locationManager.startUpdatingLocation()
        
        return locationManager.rx.didUpdateLocations
            .take(1)
            .asDriver(onErrorDriveWith: Driver.empty())
            .flatMap {
                return $0.last.map(Driver.just) ?? Driver.empty()
            }
            .map { $0.coordinate }
            .do(onNext: { [weak self] (_) in
                self?.locationManager.stopUpdatingLocation()
            })
    }
}
