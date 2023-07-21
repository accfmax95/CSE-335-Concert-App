//
//  geoAPI.swift
//  Final Project
//
//  Created by Max Berry on 11/19/22.
//

import Foundation

struct geoAPI: Decodable {
    
    var longitude: Float
    var city: String
    var latitude: Float
    
}

struct concertAPI: Decodable {
    
    var data: [concertInfo] = []
    var page: String
}

struct concertInfo: Decodable {
    
    var description: String
    var image: String
    var name: String
    
}




