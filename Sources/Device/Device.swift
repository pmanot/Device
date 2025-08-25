import Foundation
import Combine
import Battery
#if os(macOS)
import AppKit
import IOKit.ps
#else
import UIKit
#endif


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
    
    private var processInfo: ProcessInfo {
        ProcessInfo.processInfo
    }
    
    public var environment: [String: String] {
        processInfo.environment
    }
    
    public var systemUptime: TimeInterval {
        processInfo.systemUptime
    }
        
    @Published
    public var thermalState: ProcessInfo.ThermalState
    public let battery = Battery()
    
    private let thermalStatePublisher = NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)

    private init() {
        #if os(macOS)
        self.name = Host.current().localizedName ?? ProcessInfo.processInfo.hostName
        self.model = "Mac"
        self.systemName = "macOS"
        self.systemVersion = String("\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)")
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
        self.thermalState = ProcessInfo.processInfo.thermalState

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
        
        return properties
    }
}

// MARK: - Conformances

extension ProcessInfo.ThermalState: Codable { }
