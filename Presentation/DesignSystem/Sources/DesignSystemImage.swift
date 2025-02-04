//
//  DesignSystemImage.swift
//  DesignSystem
//
//  Created by A_Mcflurry on 2/2/25.
//

import Foundation
import UIKit

public enum DesignSystemImage {
    public static let btn_1x1: UIImage = UIImage(named: "btn_1x1", in: designSystemBundle, with: nil)!
    public static let btn_4x3: UIImage = UIImage(named: "btn_4x3", in: designSystemBundle, with: nil)!
    public static let btn_16x9: UIImage = UIImage(named: "btn_16x9", in: designSystemBundle, with: nil)!
    public static let btn_capture: UIImage = UIImage(named: "btn_capture", in: designSystemBundle, with: nil)!
}

extension DesignSystemImage {
    static let designSystemBundle = Bundle(identifier: "com.yoo.DesignSystem")
}
