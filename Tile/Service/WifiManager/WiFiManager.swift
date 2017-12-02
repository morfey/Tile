//
//  WiFiManager.swift
//  WifiManager
//
//  Created by Andrii Shchudlo on 30.12.15.
//  Copyright © 2015 WarWar. All rights reserved.
//

import UIKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class WiFiManager: NSObject
{
    static let sharedInstance: WiFiManager = { WiFiManager() }()
    
    func getWiFiSSIDString() -> String
    {
        let interfaces:CFArray! = CNCopySupportedInterfaces()
        for i in 0..<CFArrayGetCount(interfaces)
        {
            let interfaceName = CFArrayGetValueAtIndex(interfaces, i)
            let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
            if unsafeInterfaceData != nil {
                let interfaceData = unsafeInterfaceData! as! Dictionary<String, Any>

                return interfaceData["SSID"] as! String
            }
            else
            {
                return ""
            }
        }
        return ""
    }
    
    func getWiFiRouterMACAdrress() -> String
    {
        let ipAddress = WifiIPManager.sharedInstance.getRouterMacAddressString()
        return ipAddress
    }
}
