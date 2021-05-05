//
//  DoubleExtension.swift
//  weather-app
//
//  Copyright © 2021 semra. All rights reserved.
//

import Foundation

extension Double {
    func toString() -> String {
        return String(format: "%.1f", self);
    }
}
