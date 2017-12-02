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
    var batteryLevel: Int
    var sleeping: Bool
    var imageAngle: String
    var owner: String
    var needUpdateImage: Bool
    var needUpdateSleepingTime: Bool
    var needUpdateTime: Bool
    var needUpdateSoftware: Bool
    var needUpdateCurrentStatus: Bool
    var timeZone: String
    var chargeStatus: Bool
    var currentStatus: String
    var sleepTime: String
    var imageUrl: String?
    var otaUrl: String?
    var firmwareVersion: String?
    
    init(id: String, userId: String) {
        self.name = ""
        self.id = id
        self.batteryLevel = 45
        self.chargeStatus = false
        self.imageAngle = "auto"
        self.sleeping = false
        self.needUpdateTime = false
        self.needUpdateImage = false
        self.needUpdateSoftware = false
        self.needUpdateSleepingTime = false
        self.owner = userId
        self.timeZone = "Europe/Kiev"
        self.currentStatus = "offline"
        self.needUpdateCurrentStatus = false
        self.firmwareVersion = "1.0.0"
        self.otaUrl = "none"
        self.imageUrl = "none"
        self.sleepTime = "22:30 - 08:00"
    }
    
    mutating func add(image: String) {
        self.imageUrl = image
    }
    mutating func add(ota: String) {
        self.otaUrl = ota
    }
    
    mutating func add(firmware: String) {
        self.firmwareVersion = firmware
    }
    
    mutating func add(name: String) {
        self.name = name
    }
}

extension Tile: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.batteryLevel = try unboxer.unbox(key: "batteryLevel")
        self.sleeping = try unboxer.unbox(key: "sleeping")
        self.imageAngle = try unboxer.unbox(key: "imageAngle")
        self.owner = try unboxer.unbox(key: "owner")
        self.needUpdateImage = try unboxer.unbox(key: "needUpdateImage")
        self.needUpdateSleepingTime = try unboxer.unbox(key: "needUpdateSleepingTime")
        self.needUpdateTime = try unboxer.unbox(key: "needUpdateTime")
        self.needUpdateSoftware = try unboxer.unbox(key: "needUpdateSoftware")
        self.timeZone = try unboxer.unbox(key: "timeZone")
        self.imageUrl = unboxer.unbox(key: "imageUrl")
        self.otaUrl = unboxer.unbox(key: "otaUrl")
        self.firmwareVersion  = unboxer.unbox(key: "firmwareVersion")
        self.chargeStatus = try unboxer.unbox(key: "chargeStatus")
        self.currentStatus = try unboxer.unbox(key: "currentStatus")
        self.needUpdateCurrentStatus = try unboxer.unbox(key: "needUpdateCurrentStatus")
        self.sleepTime = try unboxer.unbox(key: "sleepTime")
    }
}
