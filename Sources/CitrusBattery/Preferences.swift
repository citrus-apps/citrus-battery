import AppKit
import CitrusKit
import Foundation
import SwiftUI

/// UserDefaults keys, shared by `@AppStorage` and non-view code.
enum PreferenceKey {
    static let temperatureUnit = "temperatureUnit"
    static let capacityUnit = "capacityUnit"
    static let capacityStyle = "capacityStyle"
    static let updateInterval = "updateInterval"
    static let powerChartPeriod = "powerChartPeriod"
    static let sleepPeriod = "sleepPeriod"
    static let appEnergyPeriod = "appEnergyPeriod"
    static let appEnergyBatteryOnly = "appEnergyBatteryOnly"
    static let autosaveNewDevices = "autosaveNewDevices"

    static let showInMenuBar = "showInMenuBar"
    static let menuBarFormat = "menuBarFormat"
    static let batterySymbol = "batterySymbol"
    static let batteryPercentInIcon = "batteryPercentInIcon"
    static let lowPowerIndicator = "lowPowerIndicator"
    static let leafUsesColour = "leafUsesColour"
    static let leafColour = "leafColour"
    static let batteryColouring = "batteryColouring"
    static let showDockIcon = "showDockIcon"
    static let startHiddenAtLogin = "startHiddenAtLogin"

    static let alertLowChargeEnabled = "alertLowChargeEnabled"
    static let alertLowChargePercent = "alertLowChargePercent"
    static let alertLowTimeEnabled = "alertLowTimeEnabled"
    static let alertLowTimeMinutes = "alertLowTimeMinutes"
    static let alertFullyCharged = "alertFullyCharged"
    static let alertDeviceChargeEnabled = "alertDeviceChargeEnabled"
    static let alertDeviceChargePercent = "alertDeviceChargePercent"
    static let showDevicesInMenuBar = "showDevicesInMenuBar"
}

/// Where the battery icon sits next to the menu bar text.
enum BatterySymbolPosition: String, CaseIterable, Identifiable {
    case none, left, right

    var id: String { rawValue }
}

/// How the menu bar shows that Low Power Mode is on.
enum LowPowerIndicator: String, CaseIterable, Identifiable {
    /// A yellow battery fill, as macOS's own icon does.
    case yellow
    /// A leaf next to the battery icon.
    case leaf
    case none

    var id: String { rawValue }
}

/// When the battery fill is coloured, apart from Low Power Mode.
enum BatteryColouring: String, CaseIterable, Identifiable {
    /// Red when nearly empty on battery, as macOS does.
    case macOS
    /// Also yellow when low on battery.
    case chargeLevel

    var id: String { rawValue }
}

/// A colour stored in UserDefaults as "#RRGGBB" (sRGB).
enum StoredColour {
    static let defaultLeaf = "#34C759"

    static func color(_ hex: String) -> Color {
        Color(nsColor: nsColor(hex) ?? nsColor(defaultLeaf)!)
    }

    static func nsColor(_ hex: String) -> NSColor? {
        let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        return NSColor(srgbRed: CGFloat((value >> 16) & 0xFF) / 255, green: CGFloat((value >> 8) & 0xFF) / 255,
                       blue: CGFloat(value & 0xFF) / 255, alpha: 1)
    }

    static func hex(_ color: Color) -> String? {
        guard let rgb = NSColor(color).usingColorSpace(.sRGB) else { return nil }
        let channel = { (value: CGFloat) in Int((min(max(value, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", channel(rgb.redComponent), channel(rgb.greenComponent),
                      channel(rgb.blueComponent))
    }
}

extension UserDefaults {
    var batteryAlertSettings: BatteryAlertSettings {
        BatteryAlertSettings(
            lowChargePercent: bool(forKey: PreferenceKey.alertLowChargeEnabled)
                ? (object(forKey: PreferenceKey.alertLowChargePercent) as? Int ?? 20) : nil,
            lowTimeMinutes: bool(forKey: PreferenceKey.alertLowTimeEnabled)
                ? (object(forKey: PreferenceKey.alertLowTimeMinutes) as? Int ?? 30) : nil,
            fullyCharged: bool(forKey: PreferenceKey.alertFullyCharged)
        )
    }
}

/// Which part of the main window is showing; shared so the menu bar can open History.
@MainActor
final class Navigator: ObservableObject {
    // CITRUS_DEBUG_OPEN=history, sleep or settings starts on that page (used for UI captures).
    @Published var selection: SidebarItem? = switch ProcessInfo.processInfo.environment["CITRUS_DEBUG_OPEN"] {
    case "history": .history
    case "sleep": .sleep
    case "settings": .settings
    default: .thisMac
    }
    @Published var settingsSection = SettingsSection.general
    /// Device shown in the Battery Lifetime Data window: `AdvancedTarget.mac` or a UDID.
    @Published var lifetimeTarget: String = AdvancedTarget.mac
}

extension UserDefaults {
    var updateInterval: UpdateInterval {
        string(forKey: PreferenceKey.updateInterval).flatMap(UpdateInterval.init(rawValue:)) ?? .delayed
    }
}

/// The macOS 27 SDK resolves `@State` to a macro whose plugin ships only with
/// full Xcode. This alias names the underlying property wrapper directly so the
/// project also builds with the Command Line Tools.
typealias ViewState = SwiftUI.State
