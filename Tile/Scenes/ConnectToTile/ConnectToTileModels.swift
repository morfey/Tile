//
//  ConnectToTileModels.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit
import Unbox

enum ConnectToTile
{
    enum NewTile
    {
        struct Request
        {
            var id: String
            var userId: String
        }
        struct Response
        {
            var tile: Tile
        }
        struct ViewModel
        {
            var tile: Tile
        }
    }
    
    enum ConnectionStatus
    {
        struct Request
        {
        }
        struct Response
        {
            var status: Bool
        }
        struct ViewModel
        {
            var alert: UIAlertController
        }
    }
}

class WifiModel: Equatable {
    var name: String = ""
    var pass: String = ""
    var isOpen: Bool?
    var signalStrength: Int?
    var jsonRepresentation : Data {
        let dict = ["name" : name, "pass" : pass]
        guard let data =  try? JSONSerialization.data(withJSONObject: dict, options: []) else { return Data()}
        return data
    }
    
    init(name: String, isOpen: Bool, signalStrength: Int) {
        self.name = name
        self.isOpen = isOpen
        self.signalStrength = signalStrength
    }
    
    func add(pass: String) {
        self.pass = pass
    }
    
    init(unboxer: Unboxer) throws {
        name   = try unboxer.unbox(key: "name")
        isOpen = unboxer.unbox(key: "isOpen")
        signalStrength = unboxer.unbox(key: "signalStrength")
    }
    
    static func ==(lhs: WifiModel, rhs: WifiModel) -> Bool {
        return lhs.name == rhs.name
    }
}
