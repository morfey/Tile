//
//  ConnectToTileModels.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

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

class WifiModel: NSObject, Codable {
    var name: String = ""
    var pass: String = ""
    var jsonRepresentation : Data {
        let dict = ["name" : name, "pass" : pass]
        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        return data
    }
    
    init(name: String, pass: String) {
        self.name = name
        self.pass = pass
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: NAME_KEY) as? String {
            self.name = name
        }
        
        if let pass = aDecoder.decodeObject(forKey: "pass") as? String {
            self.pass = pass
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: NAME_KEY)
        aCoder.encode(pass, forKey: "pass")
    }
}
