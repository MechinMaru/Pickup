//
//  PickupResponse.swift
//  Pickup
//
//  Created by MECHIN on 8/9/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import Foundation

struct PickupResponse: Decodable {
    var numberOfNewLocation: Int
    var pickup: [Pickup]
    
    enum CodingKeys: String, CodingKey {
        case numberOfNewLocation = "number_of_new_locations"
        case pickup
    }
}

