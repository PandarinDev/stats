//
//  settings.swift
//  Clock
//
//  Created by Krisztián Szabó on 2022. 08. 05..
//  Copyright © 2022. Serhiy Mytrovtsiy. All rights reserved.
//

import Kit
import AppKit


internal class Settings: NSView, Settings_v {
    
    public var selectedTimeZonesHandler: ([String]) -> Void = {_ in }
    
    private let title: String
    private var timezones: [String]
    
    public init(_ title: String) {
        self.title = title
        let timezonesStr = Store.shared.string(key: "\(self.title)_timeZones", defaultValue: "UTC")
        self.timezones = timezonesStr.components(separatedBy: ",")
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var callback: (() -> Void) = {}
    
    public func loadSettings() {
        selectedTimeZonesHandler(self.timezones)
    }
    
    public func load(widgets: [widget_t]) {
    }
    
}
