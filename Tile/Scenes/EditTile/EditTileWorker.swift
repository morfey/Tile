//
//  EditTileWorker.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

let gpuEffectConfigs: [String?] = [
    "",
    "@beautify bilateral 10 4 1 @style haze -0.5 -0.5 1 1 1 @curve RGB(0, 0)(94, 20)(160, 168)(255, 255) @curve R(0, 0)(129, 119)(255, 255)B(0, 0)(135, 151)(255, 255)RGB(0, 0)(146, 116)(255, 255)",
    "#unpack @style sketch 0.9",
    "@beautify bilateral 100 3.5 2 ",
    "@style edge 1 2 @curve RGB(0, 255)(255, 0) @adjust saturation 0 @adjust level 0.33 0.71 0.93 ",
    "@style halftone 1.2 ",
    "@adjust sharpen 10 1.5 ",
    "@curve R(0, 0)(117, 95)(155, 171)(179, 225)(255, 255)G(0, 0)(94, 66)(155, 176)(255, 255)B(0, 0)(48, 59)(141, 130)(255, 224)",
    "@adjust hsv -0.7 -0.7 0.5 -0.7 -0.7 0.5 @pixblend ol 0.243 0.07059 0.59215 1 25",
    "@adjust hsv -1 -1 -1 -1 -1 -1",
    "@adjust saturation 0 @adjust level 0 0.83921 0.8772"
]

class EditTileWorker
{
    func applyFilters(originalImage: UIImage, filtrerNames: [String]) -> [CGImage] {
        var filteredImages: [CGImage] = []
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: originalImage)
        for i in filtrerNames {
            let filter = CIFilter(name: i)
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            filteredImages.append(filteredImageRef!)
        }
        return filteredImages
    }
    
    func applyGPUImageFilters(originalImage image: UIImage) -> [CGImage] {
        var filteredImages: [CGImage] = []
        for i in 0...gpuEffectConfigs.count - 1 {
            let config = gpuEffectConfigs[i]
            if let imageWFilter = cgeFilterUIImage_MultipleEffects(image, config, 1.0, nil), let cgImage = imageWFilter.cgImage {
                filteredImages.append(cgImage)
            }
        }
        return filteredImages
    }
    
    func applyGPUImageFilter(index: Int, toImage image: UIImage) -> UIImage {
        let config = gpuEffectConfigs[index]
        if let imageWFilter = cgeFilterUIImage_MultipleEffects(image, config, 1.0, nil) {
            return imageWFilter
        }
        return image
    }
}
