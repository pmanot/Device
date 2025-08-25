//
//  File.swift
//  Device
//
//  Created by Purav Manot on 25/08/25.
//

import Foundation
#if os(macOS)
import AppKit
import IOKit.ps
#else
import UIKit
#endif

// adapted from SwiftUIX
// https://github.com/SwiftUIX/SwiftUIX
public enum UserInterfaceIdiom: String, Hashable {
    case carPlay
    case mac
    case phone
    case pad
    case tv
    case watch
    case vision
    
    case unspecified
    
    public static var current: UserInterfaceIdiom {
#if targetEnvironment(macCatalyst)
        return .mac
#elseif os(iOS) || os(tvOS)
        switch UIDevice.current.userInterfaceIdiom {
            case .carPlay:
                return .carPlay
            case .phone:
                return .phone
            case .pad:
                return .pad
            case .tv:
                return .tv
            case .mac:
                return .mac
            case .vision:
                return .vision
            case .unspecified:
                return .unspecified
                
            @unknown default:
                return .unspecified
        }
#elseif os(macOS)
        return .mac
#elseif os(watchOS)
        return .watch
#endif
    }
}
