//
//  ConnectToTileModels.swift
//  Tile
//
//  Created by  Tim on 29.11.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

enum ConnectToTile
{
    // MARK: Use cases
    
    enum Something
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
        }
    }
    
    enum NewTile
    {
        struct Request
        {
            var id: String
            var userId: String
        }
        struct Response
        {
            var status: String
            var tile: Tile
        }
        struct ViewModel
        {
            var tile: Tile
        }
    }
}

class WifiModel: NSObject, NSCoding {
    var name: String = ""
    var pass: String = ""
    
    init(name: String, pass: String) {
        self.name = name
        self.pass = pass
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        if let ver = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = ver
        }
        
        if let len = aDecoder.decodeObject(forKey: "len") as? String {
            self.pass = len
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(pass, forKey: "pass")
    }
}
