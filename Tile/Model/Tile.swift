//
//  Tile.swift
//  Tile
//
//  Created by  Tim on 24.10.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation
import Unbox

struct Tile {
    var name: String
    var id: String
    var bateryLevel: Int
    var isSleeping: Bool
    var imageAngle: String
    var owner: String
    var needUpdateImage: Bool
    var needUpdateSleepingTime: Bool
    var needUpdateTime: Bool
    var needUpdateSoftware: Bool
    var timeZone: String
    var imageUrl: URL?
    var otaUrl: URL?
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
        self.bateryLevel = 45
        self.imageAngle = "auto"
        self.isSleeping = false
        self.needUpdateTime = false
        self.needUpdateImage = false
        self.needUpdateSoftware = false
        self.needUpdateSleepingTime = false
        self.owner = ""
        self.timeZone = "Europe/Kiev"
    }
    
    mutating func add(image: URL) {
        self.imageUrl = image
    }
    mutating func add(ota: URL) {
        self.otaUrl = ota
    }
}

extension Tile: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.bateryLevel = try unboxer.unbox(key: "bateryLevel")
        self.isSleeping = try unboxer.unbox(key: "isSleeping")
        self.imageAngle = try unboxer.unbox(key: "imageAngle")
        self.owner = try unboxer.unbox(key: "owner")
        self.needUpdateImage = try unboxer.unbox(key: "needUpdateImage")
        self.needUpdateSleepingTime = try unboxer.unbox(key: "needUpdateSleepingTime")
        self.needUpdateTime = try unboxer.unbox(key: "needUpdateTime")
        self.needUpdateSoftware = try unboxer.unbox(key: "needUpdateSoftware")
        self.timeZone = try unboxer.unbox(key: "timeZone")
        self.imageUrl = unboxer.unbox(key: "imageUrl")
        self.otaUrl = unboxer.unbox(key: "otaUrl")
    }
}
