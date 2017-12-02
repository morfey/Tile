//
//  NetInfo.swift
//  Tile
//
//  Created by  Tim on 02.12.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation

struct NetInfo {
    // IP Address
    let ip: String
    
    // Netmask Address
    let netmask: String
    
    // CIDR: Classless Inter-Domain Routing
    var cidr: Int {
        var cidr = 0
        for number in binaryRepresentation(netmask) {
            let numberOfOnes = number.components(separatedBy: "1").count - 1
            cidr += numberOfOnes
        }
        return cidr
    }
    
    // Network Address
    var network: String {
        return bitwise(&, net1: ip, net2: netmask)
    }
    
    // Broadcast Address
    var broadcast: String {
        let inverted_netmask = bitwise(~, net1: netmask)
        let broadcast = bitwise(|, net1: network, net2: inverted_netmask)
        return broadcast
    }
    
    
    private func binaryRepresentation(_ s: String) -> [String] {
        var result: [String] = []
        for numbers in (s.split {$0 == "."}) {
            if let intNumber = Int(String(numbers)) {
                if let binary = Int(String(intNumber, radix: 2)) {
                    result.append(NSString(format: "%08d", binary) as String)
                }
            }
        }
        return result
    }
    
    private func bitwise(_ op: (UInt8,UInt8) -> UInt8, net1: String, net2: String) -> String {
        let net1numbers = toInts(net1)
        let net2numbers = toInts(net2)
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i],net2numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
    
    private func bitwise(_ op: (UInt8) -> UInt8, net1: String) -> String {
        let net1numbers = toInts(net1)
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
    
    private func toInts(_ networkString: String) -> [UInt8] {
        return (networkString.split {$0 == "."}).map{UInt8(String($0))!}
    }
}
