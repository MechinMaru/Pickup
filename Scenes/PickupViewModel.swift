//
//  PickupViewModel.swift
//  Pickup
//
//  Created by MECHIN on 8/9/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya
import CoreLocation

protocol PickupViewModelInput {
    var vieWDidLoadTrigger: PublishRelay<Void> { get }
    var locationButtonTrigger: PublishRelay<Void> { get }
    var onSelectedPickupItemWithId: BehaviorRelay<Int?> { get }
}

protocol PickupViewModelOutput {
    var pickupDataSource: Driver<[PickupTableViewCellData]>! { get }
    var isLoading: Driver<Bool> { get }
    var onRequestShowAlert: Driver<Void>! { get }
}

protocol PickupViewModelType {
    var input: PickupViewModelInput { get }
    var output: PickupViewModelOutput { get }
}

class PickupViewModel: PickupViewModelType, PickupViewModelInput, PickupViewModelOutput {
    
    // MARK - Input
    var vieWDidLoadTrigger = PublishRelay<Void>()
    var locationButtonTrigger = PublishRelay<Void>()
    var onSelectedPickupItemWithId = BehaviorRelay<Int?>(value: nil)

    // MARK - Output
    var pickupDataSource: Driver<[PickupTableViewCellData]>!
    
    var isLoading: Driver<Bool> {
        return _isLoading.asDriver()
    }
    
    var onRequestShowAlert: Driver<Void>!

    private let disposeBag = DisposeBag()
    private let _pickupDatasource = BehaviorRelay<[Pickup]>(value: [Pickup]())
    private let provider = MoyaProvider<PickupService>()
    private let onAPIError = PublishRelay<Error>()
    private var _isLoading = BehaviorRelay<Bool>(value: false)

    init() {
        
        vieWDidLoadTrigger
            .flatMapLatest { [weak self] (_) -> Observable<Event<PickupResponse>> in
                guard let provider = self?.provider else { return Observable.empty() }
                
                return provider.rx.request(PickupService.pickupLoactions(shopId: "1"))
                    .map(PickupResponse.self)
                    .asObservable()
                    .materialize()
            }
            .flatMapLatest { [weak self] (event) -> Observable<PickupResponse> in
                switch event {
                case .next(let element):
                   return Observable.just(element)
                case .error(let error):
                    self?.onAPIError.accept(error)
                    break
                case .completed:
                    break
                }
                return Observable.empty()
            }
            .asDriver(onErrorDriveWith: Driver.empty())
            .map { (pickupResponse) -> [Pickup] in
                let result = pickupResponse.pickup.filter{ $0.active }
                return result
            }
            .drive(_pickupDatasource)
            .disposed(by: disposeBag)

        let locationAuthorized = locationButtonTrigger
            .asObservable()
            .withLatestFrom(GeoLocationService.instance.authorizedStatus)
            .share()
        
         onRequestShowAlert = locationAuthorized
            .filter({ (status) -> Bool in
                switch status {
                case .denied,
                     .restricted:
                    return true
                default:
                    return false
                }
            })
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: Driver.empty())
        
        let currentLocation = locationAuthorized
            .filter { (status) -> Bool in
                switch status {
                    case .authorizedAlways,
                         .authorizedWhenInUse,
                         .notDetermined:
                    return true
                default:
                    return false
                }
            }
            .do(onNext: { (status) in
                if case .notDetermined = status {
                    GeoLocationService.instance.requestPermission()
                }
            })
            .flatMapLatest { (_) -> Driver<CLLocationCoordinate2D?> in
                return GeoLocationService.instance.getCurrentLocation().map { $0 }
            }
        
    
        pickupDataSource = Driver.combineLatest(_pickupDatasource.asDriver(),
                             currentLocation.asDriver(onErrorDriveWith: Driver.empty()).startWith(nil),
                             onSelectedPickupItemWithId.asDriver())
        { (pickupSource, currentLocation, isSelectedId) -> [PickupTableViewCellData] in
            
            var myLocation: CLLocation? = nil
            if let currentLocation = currentLocation {
                myLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            }
            
            let results = pickupSource.map({ (pickup) -> PickupTableViewCellData in
                var distanceInKiloMeters: Double? = nil
                if let myLocation = myLocation {
                    let pickupLocation = CLLocation(latitude: pickup.latitude, longitude: pickup.longitude)
                    distanceInKiloMeters = myLocation.distance(from: pickupLocation) / 1000
                }
                var isSelected = false
                if let isSelectedId = isSelectedId {
                    isSelected = isSelectedId == pickup.pickupLocationId
                }
                return PickupTableViewCellData(data: pickup,
                                               isSelected: isSelected,
                                               distanceInKiloMeters: distanceInKiloMeters)
            })
            
            if currentLocation != nil {
                return results.sorted(by: { (pickup1, pickup2) -> Bool in
                    guard let pickup1Distance = pickup1.distanceInKiloMeters,
                        let pickup2Distance = pickup2.distanceInKiloMeters else { return false }
                    return pickup1Distance < pickup2Distance
                })
            }
            
            return results
        }
        .asDriver()
    }
    
    var input: PickupViewModelInput { return self }
    var output: PickupViewModelOutput { return self }
}
