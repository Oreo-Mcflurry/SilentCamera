//
//  CameraRatio.swift
//  Entities
//
//  Created by A_Mcflurry on 2/2/25.
//

import UIKit

public enum CameraRatio {
    case _4x3
    case _1x1
    case _16x9
}

public extension CameraRatio {
    var ratio: Double {
        switch self {
        case ._4x3:
            return 3 / 4
        case ._1x1:
            return 1
        case ._16x9:
            return 9 / 16
        }
    }
}
