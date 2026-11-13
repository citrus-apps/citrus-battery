import Testing
@testable import CitrusBattery

@Suite struct MenuBarIconStyleTests {
    static func style(level: Double = 0.5, onBattery: Bool = true, lowPowerMode: Bool = false,
                      indicator: LowPowerIndicator = .yellow,
                      colouring: BatteryColouring = .macOS) -> MenuBarIconStyle {
        MenuBarIconStyle.resolve(level: level, onBattery: onBattery, lowPowerMode: lowPowerMode,
                                 indicator: indicator, colouring: colouring)
    }

    @Test func defaultsMatchMacOS() {
        #expect(Self.style() == MenuBarIconStyle(fill: .none, showsLeaf: false))
        #expect(Self.style(lowPowerMode: true) == MenuBarIconStyle(fill: .yellow, showsLeaf: false))
        #expect(Self.style(level: 0.10) == MenuBarIconStyle(fill: .red, showsLeaf: false))
        // Low Power Mode's yellow wins over red, as in macOS.
        #expect(Self.style(level: 0.05, lowPowerMode: true).fill == .yellow)
        // Plugged in, a nearly empty battery isn't red.
        #expect(Self.style(level: 0.05, onBattery: false).fill == .none)
        // macOS has no yellow for low charge.
        #expect(Self.style(level: 0.15).fill == .none)
    }

    @Test func leafReplacesTheYellowFill() {
        #expect(Self.style(lowPowerMode: true, indicator: .leaf) == MenuBarIconStyle(fill: .none, showsLeaf: true))
        #expect(Self.style(level: 0.05, lowPowerMode: true, indicator: .leaf)
            == MenuBarIconStyle(fill: .red, showsLeaf: true))
        #expect(Self.style(lowPowerMode: false, indicator: .leaf).showsLeaf == false)
    }

    @Test func noIndicatorLeavesTheIconPlain() {
        #expect(Self.style(lowPowerMode: true, indicator: .none) == MenuBarIconStyle(fill: .none, showsLeaf: false))
        #expect(Self.style(level: 0.05, lowPowerMode: true, indicator: .none).fill == .red)
    }

    @Test func chargeLevelColouring() {
        #expect(Self.style(level: 0.5, colouring: .chargeLevel).fill == .none)
        #expect(Self.style(level: 0.20, colouring: .chargeLevel).fill == .yellow)
        #expect(Self.style(level: 0.10, colouring: .chargeLevel).fill == .red)
        #expect(Self.style(level: 0.15, onBattery: false, colouring: .chargeLevel).fill == .none)
        #expect(Self.style(level: 0.15, lowPowerMode: true, indicator: .leaf, colouring: .chargeLevel)
            == MenuBarIconStyle(fill: .yellow, showsLeaf: true))
    }

    @Test func storedColourRoundTrips() {
        #expect(StoredColour.nsColor("#34C759") != nil)
        #expect(StoredColour.nsColor("nope") == nil)
        #expect(StoredColour.hex(StoredColour.color("#34C759")) == "#34C759")
    }
}
