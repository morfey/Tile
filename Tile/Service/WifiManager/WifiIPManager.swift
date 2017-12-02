//
//  WifiIPManager.swift
//  WifiManager
//
//  Created by Andrii Shchudlo on 31.12.15.
//  Copyright © 2015 WarWar. All rights reserved.
//

import UIKit

class WifiIPManager: NSObject
{
////    let netmask = getIFAddresses().last!.netmask
    
    static let sharedInstance: WifiIPManager = { WifiIPManager() }()
    
    func getRouterIpAddressString() -> String
    {
        let objectiveIpClass:IPObjectiveManager = IPObjectiveManager()
        return objectiveIpClass.getGatewayIP()
    }
    
    func getRouterMacAddressString() -> String
    {
        let temporaryIpString = getRouterIpAddressString()
        if temporaryIpString == ""
        {
            return ""
        }
        else
        {
            let objectiveCMACManager:MacAddressManager = MacAddressManager()
            let ipString = (temporaryIpString as NSString).utf8String
            let ip = UnsafeMutablePointer<Int8>(mutating: ipString)
            
            return objectiveCMACManager.getMacFromIp(ip)
        }
    }
}
