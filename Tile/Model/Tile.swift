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
    var time: Int
    var imageUrl: String?
    var otaUrl: String?
    var firmwareVersion: String?
//    var isSleeping: Bool?
    
    init(id: String, userId: String) {
        self.name = ""
        self.id = id
        self.batteryLevel = 60
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
        self.time = Int(Date().timeIntervalSince1970)
//        rself.isSleeping = false
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
        self.id = try unboxer.unbox(key: ID_KEY)
        self.name = try unboxer.unbox(key: NAME_KEY)
        self.batteryLevel = try unboxer.unbox(key: BATTERY_KEY)
        self.sleeping = try unboxer.unbox(key: SLEEPING_KEY)
        self.imageAngle = try unboxer.unbox(key: IMAGEANGLE_KEY)
        self.owner = try unboxer.unbox(key: OWNER_KEY)
        self.needUpdateImage = try unboxer.unbox(key: NEEDUPDATEIMAGE_KEY)
        self.needUpdateSleepingTime = try unboxer.unbox(key: NEEDUPDATESLEEPINGTIME_KEY)
        self.needUpdateTime = try unboxer.unbox(key: NEEDUPDATETIME_KEY)
        self.needUpdateSoftware = try unboxer.unbox(key: NEEDUPDATESOFTWARE_KEY)
        self.timeZone = try unboxer.unbox(key: TIMEZONE_KEY)
        self.imageUrl = unboxer.unbox(key: IMAGEURL_KEY)
        self.otaUrl = unboxer.unbox(key: OTAURL_KEY)
        self.firmwareVersion  = unboxer.unbox(key: FIRMWAREVERSION_KEY)
        self.chargeStatus = try unboxer.unbox(key: CHARGESTATUS_KEY)
        self.currentStatus = try unboxer.unbox(key: CURRENTSTATUS_KEY)
        self.needUpdateCurrentStatus = try unboxer.unbox(key: NEEDUPDATECURRENTSTATUS_KEY)
        self.sleepTime = try unboxer.unbox(key: SLEEPTIME_KEY)
        self.time = try unboxer.unbox(key: TIME_KEY)
//        self.isSleeping = unboxer.unbox(key: ISSLEPPING_KEY)
    }
}
