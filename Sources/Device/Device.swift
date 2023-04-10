import Foundation
import Combine
import SwiftUI
import Battery
#if os(macOS)
import AppKit
import IOKit.ps
#else
import UIKit
#endif

// MARK: - Class

public class Device: ObservableObject {
    public static let current = Device()
    
    public var name: String
    public var userName: String
    public var fullUserName: String
    public var model: String
    public var systemName: String
    public var systemVersion: String
    public var operatingSystemVersion: OperatingSystemVersion { processInfo.operatingSystemVersion }
    public var operatingSystemVersionString: String { processInfo.operatingSystemVersionString }
    public var processorCount: Int { processInfo.processorCount }
    public var activeProcessorCount: Int { processInfo.activeProcessorCount }
    public var isMacCatalystApp: Bool { processInfo.isMacCatalystApp }
    public var isIOSAppOnMac: Bool { processInfo.isiOSAppOnMac }
    public var userInterfaceIdiom: UserInterfaceIdiom = UserInterfaceIdiom.current
    
    public var environment: [String: String] {
        ProcessInfo.processInfo.environment
    }
    
    public var systemUptime: TimeInterval {
        processInfo.systemUptime
    }
        
    @Published public var thermalState: ProcessInfo.ThermalState
    
    public let battery = Battery()
    
    private let thermalStatePublisher = NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
    private let processInfo = ProcessInfo.processInfo

    private init() {
        #if os(macOS)
        self.name = Host.current().localizedName ?? processInfo.hostName
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = String("\(processInfo.operatingSystemVersion.majorVersion).\(processInfo.operatingSystemVersion.minorVersion)")
        self.userInterfaceIdiom = .mac
        
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        let currentDevice = UIDevice.current
        
        self.name = currentDevice.name
        self.model = currentDevice.model
        self.systemName = currentDevice.systemName
        self.systemVersion = currentDevice.systemVersion
        #endif
        
        self.userName = NSUserName()
        self.fullUserName = NSFullUserName()
        self.thermalState = processInfo.thermalState

        thermalStatePublisher
            .map { _ in ProcessInfo.processInfo.thermalState }
            .assign(to: &$thermalState)
    }
    
    public func attributes() -> [String: String] {
        var properties = [String: String]()
        let mirror = Mirror(reflecting: self)
        
        for case let (label?, value) in mirror.children {
            let stringValue: String
            
            if let convertibleValue = value as? LosslessStringConvertible {
                stringValue = NSString(string: convertibleValue.description) as String
            } else {
                continue
            }
            
            properties[label] = stringValue
        }
        print(properties)
        
        return properties
    }
}




// MARK: - Structure -

public struct DeviceDetails: Codable {
    public let name: String
    public let userName: String?
    public let model: String
    public let systemName: String
    public let systemVersion: String
    public let isBatteryMonitoringEnabled: Bool
    public let operatingSystemVersion: OperatingSystemVersion
    public let processorCount: Int
    public let thermalState: ProcessInfo.ThermalState
    public let batteryPercentage: Int
    public let isLowPowerModeEnabled: Bool
    
    public var systemUptime: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }
    
    public init() {
        let processInfo = ProcessInfo.processInfo
        
        #if os(macOS)
        self.name = processInfo.hostName
        self.userName = processInfo.userName
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = processInfo.operatingSystemVersionString
        self.isBatteryMonitoringEnabled = false
        
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        let currentDevice = UIDevice.current
        self.name = currentDevice.name
        self.userName = nil
        self.model = currentDevice.model
        self.systemName = currentDevice.systemName
        self.systemVersion = currentDevice.systemVersion
        self.isBatteryMonitoringEnabled = currentDevice.isBatteryMonitoringEnabled
        #endif
        
        self.operatingSystemVersion = processInfo.operatingSystemVersion
        self.processorCount = processInfo.processorCount
        self.thermalState = processInfo.thermalState
        self.isLowPowerModeEnabled = processInfo.isLowPowerModeEnabled
        self.batteryPercentage = Battery().percentage
    }
}

// MARK: - Conformances

// MARK: Codable
extension OperatingSystemVersion: Codable {
    private enum CodingKeys: String, CodingKey {
        case majorVersion = "major"
        case minorVersion = "minor"
        case patchVersion = "patch"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let majorVersion = try container.decode(Int.self, forKey: .majorVersion)
        let minorVersion = try container.decode(Int.self, forKey: .minorVersion)
        let patchVersion = try container.decode(Int.self, forKey: .patchVersion)

        self.init(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.majorVersion, forKey: .majorVersion)
        try container.encode(self.minorVersion, forKey: .minorVersion)
        try container.encode(self.patchVersion, forKey: .patchVersion)
    }
}

extension ProcessInfo.ThermalState: Codable { }

// MARK: - UserInterfaceIdiom
/// from SwiftUIX
public enum UserInterfaceIdiom: Hashable {
    case carPlay
    case mac
    case phone
    case pad
    case tv
    case watch
    
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
            #if swift(>=5.3)
            case .mac:
                return .mac
            #endif
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
