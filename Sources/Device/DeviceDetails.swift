//
//  File.swift
//  Device
//
//  Created by Purav Manot on 25/08/25.
//

import Foundation
import Battery
#if os(macOS)
import AppKit
import IOKit.ps
#else
import UIKit
#endif


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
