//
//  main.swift
//  Clock
//
//  Created by Krisztián Szabó on 2022. 08. 05..
//  Copyright © 2022. Serhiy Mytrovtsiy. All rights reserved.
//

import Kit
import Foundation

public class Clock: Module {
    
    private let settingsView: Settings
    private let popupView: Popup
    private let reader: ClockReader
    private var timeZones: [String]
    
    public init() {
        self.popupView = Popup()
        self.settingsView = Settings("Clock")
        self.reader = ClockReader()
        self.timeZones = ["UTC"]
        super.init(popup: popupView, settings: settingsView)
        self.settingsView.selectedTimeZonesHandler = handleSelectedTimeZonesChanged
        self.reader.callbackHandler = clockReadCallback
        self.addReader(reader)
        self.readyHandler()
        self.settingsView.loadSettings()
    }
    
    private func clockReadCallback(maybeDate: Date?) {
        guard let date = maybeDate else {
            return
        }
        // Update widgets
        self.menuBar.widgets.filter{ $0.isActive }.forEach{ (widget: Widget) in
            switch widget.item {
            case let clocks as Clocks:
                clocks.setTimes(timeZones.map { (date, $0) })
                break;
            default: break;
            }
        }
        // Update popup
        self.popupView.clocks.forEach { clock in
            clock.handsView.setTime(time: date)
        }
    }
    
    private func handleSelectedTimeZonesChanged(timeZones: [String]) {
        self.timeZones = timeZones
        self.popupView.handleTimeZonesChanged(timeZoneIdentifiers: self.timeZones)
    }
    
}
