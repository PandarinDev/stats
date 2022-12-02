//
//  Clock.swift
//  Kit
//
//  Created by Krisztián Szabó on 2022. 08. 05..
//  Copyright © 2022. Serhiy Mytrovtsiy. All rights reserved.
//

import Foundation
import AppKit

public class Clocks: WidgetWrapper {
    
    private static let MAX_DISPLAYED_CLOCKS = 2
    
    private let valueSize: CGFloat = 9
    private var times: [(Date, String)] = []
    private var dateFormatters: [String: DateFormatter] = [:]
    
    public init(title: String, config: NSDictionary?, preview: Bool = false) {
        super.init(.clock, title: title, frame: CGRect(
            x: 0,
            y: Constants.Widget.margin.y,
            width: Constants.Widget.width + (2 * Constants.Widget.margin.x),
            height: Constants.Widget.height - (2 * Constants.Widget.margin.y)
        ))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let systemFont = NSFont.monospacedDigitSystemFont(ofSize: valueSize, weight: .light)
        let stringAttributes = [
            NSAttributedString.Key.font: systemFont,
            NSAttributedString.Key.foregroundColor: isDarkMode ? NSColor.white : NSColor.textColor
        ]
        var maxWidth: CGFloat = 0
        let clockCountToDisplay = min(Clocks.MAX_DISPLAYED_CLOCKS, times.count)
        let rowHeight = self.frame.height / CGFloat(clockCountToDisplay)
        for (i, (time, zoneIdentifier)) in times[0..<clockCountToDisplay].enumerated() {
            guard let formatter = dateFormatters[zoneIdentifier] else {
                continue
            }
            let timeStr = NSAttributedString.init(string: formatter.string(from: time), attributes: stringAttributes)
            let width = timeStr.string.widthOfString(usingFont: systemFont)
            if width > maxWidth {
                maxWidth = width
            }
            let y = CGFloat(clockCountToDisplay - 1 - i) * rowHeight
            let rect = CGRect(x: 0, y: y, width: self.frame.width, height: rowHeight)
            timeStr.draw(with: rect)
        }
        self.setWidth(maxWidth)
    }
    
    public func setTimes(_ times: [(Date, String)]) {
        self.times = times
        self.dateFormatters.removeAll(keepingCapacity: true)
        for (_, zoneIdentifiner) in times {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: zoneIdentifiner)
            formatter.dateFormat = "YYYY/MM/dd HH:mm:ss '\(zoneIdentifiner)'"
            dateFormatters[zoneIdentifiner] = formatter
        }
        DispatchQueue.main.async(execute: {
            self.display()
        })
    }
    
}
