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
    
    var name: String
    var userName: String?
    var model: String
    var systemName: String
    var systemVersion: String
    var operatingSystemVersion: OperatingSystemVersion { processInfo.operatingSystemVersion }
    var operatingSystemVersionString: String { processInfo.operatingSystemVersionString }
    var processorCount: Int { processInfo.processorCount }
    var activeProcessorCount: Int { processInfo.activeProcessorCount }
    var isMacCatalystApp: Bool { processInfo.isMacCatalystApp }
    var isIOSAppOnMac: Bool { processInfo.isiOSAppOnMac }
    var userInterfaceIdiom: UserInterfaceIdiom = UserInterfaceIdiom.current
        
    @Published var thermalState: ProcessInfo.ThermalState
    
    let battery = Battery()
    
    private let thermalStatePublisher = NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
    private let processInfo = ProcessInfo.processInfo
    
    var systemUptime: TimeInterval {
        processInfo.systemUptime
    }
    
    
    private init() {
        #if os(macOS)
        self.name = Host.current().name ?? processInfo.hostName
        self.userName = processInfo.userName
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = String("\(processInfo.operatingSystemVersion.majorVersion).\(processInfo.operatingSystemVersion.minorVersion)")
        self.userInterfaceIdiom = .mac
        
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        let currentDevice = UIDevice.current
        
        self.name = currentDevice.name
        self.userName = nil
        self.model = currentDevice.model
        self.systemName = currentDevice.systemName
        self.systemVersion = currentDevice.systemVersion
        #endif
        
        self.thermalState = processInfo.thermalState
        
        //batteryLevelPublisher
       //     .map { _ in UIDevice.current.batteryLevel }
        //    .assign(to: &$batteryLevel)
        
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

struct DeviceDetails: Codable {
    let name: String
    let userName: String?
    let model: String
    let systemName: String
    let systemVersion: String
    let isBatteryMonitoringEnabled: Bool
    let operatingSystemVersion: OperatingSystemVersion
    let processorCount: Int
    let thermalState: ProcessInfo.ThermalState
    let batteryPercentage: Int
    let isLowPowerModeEnabled: Bool
    
    var systemUptime: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }
    
    init() {
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
