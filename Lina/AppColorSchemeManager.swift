//
//  AppColorSchemeManager.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/06/03.
//

import UIKit

class AppColorSchemeManager {
    enum ColorScheme: String, CaseIterable {
        case systemBlue
        case systemGreen
        case systemOrange
        case systemRed
        case systemPurple
        
        var color: UIColor {
            switch self {
            case .systemBlue: return .systemBlue
            case .systemGreen: return .systemGreen
            case .systemOrange: return .systemOrange
            case .systemRed: return .systemRed
            case .systemPurple: return .systemPurple
            }
        }
        
        var displayName: String {
            switch self {
            case .systemBlue: return "Blue"
            case .systemGreen: return "Green"
            case .systemOrange: return "Orange"
            case .systemRed: return "Red"
            case .systemPurple: return "Purple"
            }
        }
    }
    
    static var current: ColorScheme {
        if let savedScheme = UserDefaults.standard.string(forKey: "appColorScheme"),
           let scheme = ColorScheme(rawValue: savedScheme) {
            return scheme
        }
        return .systemBlue
    }
    
    static func setCurrentScheme(_ scheme: ColorScheme) {
        UserDefaults.standard.set(scheme.rawValue, forKey: "appColorScheme")
    }
}
