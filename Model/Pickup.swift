//
//  Pickup.swift
//  Pickup
//
//  Created by MECHIN on 8/9/19.
//  Copyright © 2019 mechin. All rights reserved.
//

import Foundation


struct Pickup: Decodable {
   
    var feature: String?
    var pickupLocationId: Int
    var countryId: Int
    var stateId: Int
    var carrierId: Int
    var company: String
    var alias: String
    var address1: String
    var address2: String
    var district: String?
    var city: String
    var postcode: String
    var latitude: Double
    var longitude: Double
    var nearestBTS: String?
    var notableArea: String?
    var hours1: String?
    var hours2: String?
    var description: String
    var isFeatured: Bool
    var subtype: String
    var active: Bool
    var status: String
    var zoneId: Int
    var isNewLocation: Bool
    var type: String
    
    enum CodingKeys: String, CodingKey {
        case feature
        case pickupLocationId = "id_pickup_location"
        case countryId = "id_country"
        case stateId = "id_state"
        case carrierId = "id_carrier"
        case company
        case alias
        case address1
        case address2
        case district
        case city
        case postcode
        case latitude
        case longitude
        case nearestBTS = "nearest_bts"
        case notableArea = "notable_area"
        case hours1
        case hours2
        case description
        case isFeatured = "is_featured"
        case subtype
        case active
        case status
        case zoneId = "id_zone"
        case isNewLocation = "is_new_location"
        case type
    }
}
