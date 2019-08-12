//
//  PickupService.swift
//  Pickup
//
//  Created by MECHIN on 8/9/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import Foundation
import Moya

enum PickupService {
    case pickupLoactions(shopId: String)
}

extension PickupService: TargetType {
    var baseURL: URL {
        return URL(string: "https://docky-staging-api.pmlo.co/v3")!
    }
    
    var path: String {
        switch self {
        case .pickupLoactions:
            return "/pickup-locations/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .pickupLoactions:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .pickupLoactions:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        case .pickupLoactions(let shopId):
            return .requestParameters(parameters: ["shop_id": shopId],
                                      encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
