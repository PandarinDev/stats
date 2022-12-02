//
//  popup.swift
//  Clock
//
//  Created by Krisztián Szabó on 2022. 08. 05..
//  Copyright © 2022. Serhiy Mytrovtsiy. All rights reserved.
//

import Kit
import AppKit

internal class Popup: NSStackView, Popup_p {
    
    private static let GAP_BETWEEN_CLOCKS = CGFloat(5)
    
    public var sizeCallback: ((NSSize) -> Void)? = nil
    public var clocks: [ClockView] = []
    
    public init() {
        super.init(frame: NSRect(x: 0, y: 0, width: Constants.Popup.width, height: 0))
        self.orientation = .vertical
        self.alignment = .top
        self.distribution = .fill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func handleTimeZonesChanged(timeZoneIdentifiers: [String]) {
        self.clocks = timeZoneIdentifiers.enumerated().map { (i, timeZone) in
            let reversedIndex = timeZoneIdentifiers.count - 1 - i
            let yOffset = ClockView.HEIGHT * CGFloat(reversedIndex) + CGFloat(reversedIndex) * Popup.GAP_BETWEEN_CLOCKS
            return ClockView(timeZoneIdentifier: timeZone, yOffset: yOffset)
        }
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.clocks.forEach { clock in
            self.addSubview(clock)
        }
        let totalClockHeight = CGFloat(clocks.count) * ClockView.HEIGHT
        let totalClockGaps = CGFloat(clocks.count - 1) * Popup.GAP_BETWEEN_CLOCKS
        sizeCallback!(NSSize(width: Constants.Popup.width, height: totalClockHeight + totalClockGaps))
    }
    
    public func settings() -> NSView? {
        nil
    }
    
}

internal class ClockView: NSStackView {
    
    public static let HEIGHT = CGFloat(ClockHandsView.CLOCK_RADIUS * 2)
    
    private let timeZoneIdentifier: String
    private let timeZone: TimeZone
    private let formatter: DateFormatter
    private let clockNameTextField: NSTextField
    private let clockTimeTextField: NSTextField
    private let handsView: ClockHandsView
    
    public init(timeZoneIdentifier: String, yOffset: CGFloat) {
        self.timeZoneIdentifier = timeZoneIdentifier
        self.timeZone = TimeZone(identifier: timeZoneIdentifier)!
        self.formatter = DateFormatter()
        self.formatter.timeZone = TimeZone(identifier: "GMT")!
        self.formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        
        let labelView = NSStackView(frame: NSRect(x: 0, y: 0, width: Constants.Popup.width, height: ClockView.HEIGHT))
        labelView.orientation = .vertical
        self.clockNameTextField = TextView(frame: CGRect.zero)
        self.clockNameTextField.stringValue = timeZoneIdentifier
        self.clockTimeTextField = TextView(frame: CGRect.zero)
        self.handsView = ClockHandsView()
        super.init(frame: NSRect(x: 0, y: yOffset, width: Constants.Popup.width, height: ClockView.HEIGHT))
        self.orientation = .horizontal
        self.distribution = .fill
        self.spacing = 5
        self.addArrangedSubview(self.handsView)
        labelView.addArrangedSubview(clockNameTextField)
        labelView.addArrangedSubview(clockTimeTextField)
        self.addArrangedSubview(labelView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTime(_ time: Date) {
        let adjustedTime = adjustToTimeZone(time)
        DispatchQueue.main.async {
            self.clockTimeTextField.stringValue = self.formatter.string(from: adjustedTime)
        }
        handsView.setTime(adjustedTime)
    }
    
    private func adjustToTimeZone(_ time: Date) -> Date {
        let offsetSeconds = timeZone.secondsFromGMT()
        let timestamp = time.timeIntervalSince1970
        return Date(timeIntervalSince1970: timestamp + Double(offsetSeconds))
    }
    
}

internal class ClockHandsView: NSView {
    
    public static let CLOCK_RADIUS = 25.0
    private static let HOURS_HAND_LENGTH = 0.40 * CLOCK_RADIUS
    private static let MINUTES_HAND_LENGTH = 0.75 * CLOCK_RADIUS
    private static let SECONDS_HAND_LENGTH = 0.85 * CLOCK_RADIUS
    private static let HOURS_HAND_LINE_WIDTH = 2.0
    private static let MINUTES_HAND_LINE_WIDTH = 1.5
    private static let SECONDS_HAND_LINE_WIDTH = 1.0
    
    private var time: Date?
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: ClockHandsView.CLOCK_RADIUS * 2, height: ClockHandsView.CLOCK_RADIUS * 2)
    }
    
    public init() {
        super.init(frame: NSRect(x: 0, y: 0, width: ClockHandsView.CLOCK_RADIUS * 2, height: ClockHandsView.CLOCK_RADIUS * 2))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTime(_ time: Date) {
        self.time = time
        DispatchQueue.main.async {
            self.display()
        }
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        guard let time = time else { return }
        context.setShouldAntialias(true)
        context.setFillColor(NSColor.red.cgColor)
        context.beginPath()
        let width = Int(ClockHandsView.CLOCK_RADIUS) * 2
        let height = Int(ClockHandsView.CLOCK_RADIUS) * 2
        context.addEllipse(in: CGRect(x: 0, y: 0, width: width, height: height))
        context.clip()
        let colors = [
            CGColor(red: 0.25, green: 0.84, blue: 0.41, alpha: 1.0),
            CGColor(red: 0.14, green: 0.58, blue: 0.25, alpha: 1.0)
        ] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil)!
        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: width, y: height), options: [])
        context.fillPath()
        
        let calendar = Calendar.current
        let hours = Double(calendar.component(.hour, from: time))
        let minutes = Double(calendar.component(.minute, from: time))
        let seconds = Double(calendar.component(.second, from: time))
        let hoursRadians = hours / 12.0 * 2.0 * Double.pi + 0.5 * Double.pi
        let minutesRadians = minutes / 60.0 * 2.0 * Double.pi + 0.5 * Double.pi
        let secondsRadians = seconds / 60.0 * 2.0 * Double.pi + 0.5 * Double.pi
        // Compute coordinates for hours hand
        let hoursHandY = sin(hoursRadians) * ClockHandsView.HOURS_HAND_LENGTH + ClockHandsView.CLOCK_RADIUS
        let hoursHandX = -cos(hoursRadians) * ClockHandsView.HOURS_HAND_LENGTH + ClockHandsView.CLOCK_RADIUS
        // Compute coordinates for minutes hand
        let minutesHandY = sin(minutesRadians) * ClockHandsView.MINUTES_HAND_LENGTH + ClockHandsView.CLOCK_RADIUS
        let minutesHandX = -cos(minutesRadians) * ClockHandsView.MINUTES_HAND_LENGTH + ClockHandsView.CLOCK_RADIUS
        // Compute coordinates for seconds hand
        let secondsHandY = sin(secondsRadians) * ClockHandsView.SECONDS_HAND_LENGTH + ClockHandsView.CLOCK_RADIUS
        let secondsHandX = -cos(secondsRadians) * ClockHandsView.SECONDS_HAND_LENGTH + ClockHandsView.CLOCK_RADIUS
        
        let center = CGPoint(x: 25, y: 25)
        context.setStrokeColor(NSColor.white.cgColor)
        
        // Draw ticks for every hour
        let clockCenter = CGFloat(ClockHandsView.CLOCK_RADIUS)
        for i in 0..<12 {
            let radians = 2.0 * Double.pi * (Double(i) / 12.0);
            let x = cos(radians)
            let y = sin(radians)
            let start = CGPoint(x: clockCenter + x * ClockHandsView.CLOCK_RADIUS * 0.8, y: clockCenter + y * ClockHandsView.CLOCK_RADIUS * 0.8)
            let end = CGPoint(x: clockCenter + x * ClockHandsView.CLOCK_RADIUS * 0.9, y: clockCenter + y * ClockHandsView.CLOCK_RADIUS * 0.9)
            context.move(to: start)
            context.addLine(to: end)
            context.drawPath(using: .fillStroke)
        }
        
        // Draw hours hand
        context.move(to: center)
        context.setLineWidth(ClockHandsView.HOURS_HAND_LINE_WIDTH)
        context.addLine(to: CGPoint(x: hoursHandX, y: hoursHandY))
        context.drawPath(using: .fillStroke)
        
        // Draw minutes hand
        context.move(to: center)
        context.setLineWidth(ClockHandsView.MINUTES_HAND_LINE_WIDTH)
        context.addLine(to: CGPoint(x: minutesHandX, y: minutesHandY))
        context.drawPath(using: .fillStroke)
        
        // Draw seconds hand
        context.move(to: center)
        context.setLineWidth(ClockHandsView.SECONDS_HAND_LINE_WIDTH)
        context.addLine(to: CGPoint(x: secondsHandX, y: secondsHandY))
        context.drawPath(using: .fillStroke)
    }
    
}
