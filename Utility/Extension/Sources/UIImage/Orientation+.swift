//
//  Orientation+.swift
//  Extension
//
//  Created by A_Mcflurry on 2/2/25.
//

import UIKit

public extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up { return self }
        
        return UIGraphicsImageRenderer(size: self.size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
    }
}
