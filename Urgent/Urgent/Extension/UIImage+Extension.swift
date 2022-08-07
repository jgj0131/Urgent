//
//  UIImage+Extension.swift
//  Urgent
//
//  Created by jang gukjin on 2022/08/07.
//  Copyright © 2022 jang gukjin. All rights reserved.
//

import Foundation

extension UIImage {
    func filled(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let mask = self.cgImage else { return self }
        context.clip(to: rect, mask: mask)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static let pin = UIImage(named: "pin")?.filled(with: .green)
    static let pin2 = UIImage(named: "pin2")?.filled(with: .green)
    static let me = UIImage(named: "me")?.filled(with: .blue)
}
