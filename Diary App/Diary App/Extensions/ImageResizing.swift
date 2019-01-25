//
//  ImageResizing.swift
//  Diary App
//
//  Created by Kate Duncan-Welke on 1/24/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resize(toPercent percent: CGFloat) -> UIImage {
        if percent == 1.0 {
            return self
        }
        guard let cgimg = self.cgImage else { return self }
        let sourceSize = CGSize(width: CGFloat(cgimg.width), height: CGFloat(cgimg.height))
        var destinationSize = CGSize(width: sourceSize.width * percent, height: sourceSize.height * percent)
        let orientation = self.imageOrientation
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case .up:
            transform = .identity
        case .upMirrored:
            transform = .init(translationX: sourceSize.width, y: 0.0)
            transform = .init(scaleX: -1.0, y: 1.0)
        case .down:
            transform = .init(translationX: sourceSize.width, y: sourceSize.height)
            transform = .init(rotationAngle: CGFloat(Double.pi))
        case .downMirrored:
            transform = .init(translationX: 0.0, y: sourceSize.height)
            transform = .init(scaleX: -1.0, y: 1.0)
        case .leftMirrored:
            (destinationSize.width, destinationSize.height) = (destinationSize.height, destinationSize.width)
            transform = .init(translationX: sourceSize.height, y: sourceSize.width)
            transform = .init(scaleX: -1.0, y: 1.0)
            transform = .init(rotationAngle: 3.0 * CGFloat(Double.pi / 2))
        case .left:
            (destinationSize.width, destinationSize.height) = (destinationSize.height, destinationSize.width)
            transform = .init(translationX: 0.0, y: sourceSize.width)
            transform = .init(rotationAngle: 3.0 * CGFloat(Double.pi / 2))
        case .rightMirrored:
            (destinationSize.width, destinationSize.height) = (destinationSize.height, destinationSize.width)
            transform = .init(scaleX: -1.0, y: 1.0)
            transform = .init(rotationAngle: CGFloat(Double.pi / 2))
        case .right:
            (destinationSize.width, destinationSize.height) = (destinationSize.height, destinationSize.width)
            transform = .init(translationX: sourceSize.height, y: 0.0)
            transform = .init(rotationAngle: CGFloat(Double.pi / 2))
        default:
            assertionFailure("Unknown image orientation: \(orientation)")
        }
        
        let destinationRect = CGRect(origin: .zero, size: sourceSize)
        UIGraphicsBeginImageContextWithOptions(destinationSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        if orientation == .right || orientation == .left {
            context?.scaleBy(x: -percent, y: percent)
            context?.translateBy(x: -sourceSize.height, y: 0.0)
        } else {
            context?.scaleBy(x: percent, y: -percent)
            context?.translateBy(x: 0.0, y: -sourceSize.height)
        }
        context?.concatenate(transform)
        context?.interpolationQuality = .high
        context?.draw(cgimg, in: destinationRect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
