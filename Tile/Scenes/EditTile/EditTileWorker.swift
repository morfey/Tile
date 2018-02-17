//
//  EditTileWorker.swift
//  Tile
//
//  Created by  Tim on 16.10.2017.
//  Copyright (c) 2017 TimHazhyi. All rights reserved.

import UIKit

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
