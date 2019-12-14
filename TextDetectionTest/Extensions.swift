//
//  Extensions.swift
//  TextDetectionTest
//
//  Created by 荒居秀尚 on 13.12.19.
//  Copyright © 2019 荒居秀尚. All rights reserved.
//

import UIKit
import CoreGraphics
import ImageIO
import Foundation


extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}

extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height)
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            fatalError("unknow orientation")
        }
    }
}

extension UIImage {
    func drawBoundingBox(boundingBoxes bboxes: [CGRect]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        self.draw(in: CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height))

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(CGColor(srgbRed: 255, green: 217, blue: 0, alpha: 0.3))
        context.fill(bboxes)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawDetectedText(texts: [String], points: [CGPoint]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        self.draw(in: CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height)
        )
        
        let pair = zip(texts, points)
        
        pair.forEach { (text, point) in
            let writeString = NSAttributedString(
                string: text,
                attributes: [
                    .font: UIFont(name: "Apple SD Gothic Neo", size: 12)!,
                    .foregroundColor: UIColor.black
            ])
            writeString.draw(at: CGPoint(x: point.x, y: point.y - 12))
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}
