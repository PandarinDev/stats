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
    
    public var sizeCallback: ((NSSize) -> Void)? = nil
    public let clocks: [ClockView]
    
    public init() {
        self.clocks = [
            ClockView(timeZoneIdentifier: "UTC", yOffset: 0),
            ClockView(timeZoneIdentifier: "Europe/Budapest", yOffset: 60.0)
        ]
        super.init(frame: NSRect(x: 0, y: 0, width: Constants.Popup.width, height: CGFloat(self.clocks.count) * 60.0))
        self.orientation = .vertical
        self.alignment = .top
        self.distribution = .fill
        self.clocks.forEach { clock in
            self.addSubview(clock)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func handleTimeZonesChanged(timeZoneIdentifiers: [String]) {
    }
    
}

internal class ClockView: NSStackView {
    
    private let timeZoneIdentifier: String
    private let clockNameTextField: NSTextField
    public let handsView: ClockHandsView
    
    public init(timeZoneIdentifier: String, yOffset: CGFloat) {
        self.timeZoneIdentifier = timeZoneIdentifier
        self.clockNameTextField = NSTextField(string: timeZoneIdentifier)
        self.clockNameTextField.isBezeled = false
        self.clockNameTextField.isEditable = false
        self.clockNameTextField.isSelectable = false
        self.handsView = ClockHandsView()
        super.init(frame: NSRect(x: 0, y: yOffset, width: Constants.Popup.width, height: 50))
        self.orientation = .horizontal
        self.spacing = 5
        self.addView(self.handsView, in: .leading)
        self.addView(self.clockNameTextField, in: .center)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

internal class ClockHandsView: NSView {
    
    private static let CLOCK_RADIUS = 25.0
    private static let HOURS_HAND_LENGTH = 0.40 * CLOCK_RADIUS
    private static let MINUTES_HAND_LENGTH = 0.75 * CLOCK_RADIUS
    private static let SECONDS_HAND_LENGTH = 0.85 * CLOCK_RADIUS
    private static let HOURS_HAND_LINE_WIDTH = 2.0
    private static let MINUTES_HAND_LINE_WIDTH = 1.5
    private static let SECONDS_HAND_LINE_WIDTH = 1.0
    
    private var time: Date?
    
    public init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setTime(time: Date) {
        self.time = time
        DispatchQueue.main.async {
            self.display()
        }
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        guard let time = time else { return }
        context.setShouldAntialias(true)
        context.setFillColor(NSColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: Int(ClockHandsView.CLOCK_RADIUS) * 2, height: Int(ClockHandsView.CLOCK_RADIUS) * 2))
        
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
