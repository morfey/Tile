//
//  GPUimagePlusDelegate.swift
//  Tile
//
//  Created by  Tim on 28.11.2017.
//  Copyright © 2017 TimHazhyi. All rights reserved.
//

import Foundation

public protocol GPUimagePlusDelegate {
    func proccessFilters(image: UIImage) -> ([CGImage])
}
