//
//  Extensions.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 24.04.2022.
//

import Foundation

extension NumberFormatter {
    static let TwoDigitNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        return formatter
    }()
}

struct TwoDigitInt: FormatStyle {
    func format(_ value: Int) -> String {
        String(format: "%02d", value)
    }
}

extension FormatStyle where Self == TwoDigitInt {
    static var twoDigitNumber: TwoDigitInt {
        TwoDigitInt()
    }
}

