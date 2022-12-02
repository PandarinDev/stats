//
//  settings.swift
//  Clock
//
//  Created by Krisztián Szabó on 2022. 08. 05..
//  Copyright © 2022. Serhiy Mytrovtsiy. All rights reserved.
//

import Kit
import AppKit


internal class Settings: NSStackView, Settings_v {
    
    public var selectedTimeZonesHandler: ([String]) -> Void = {_ in }
    
    private let title: String
    private var timeZones: [String]
    private let timeZonesDataSource: ComboBoxStringDataSource
    private var timeZoneNameComboBox: NSComboBox!
    
    public init(_ title: String) {
        self.title = title
        let timezonesStr = Store.shared.string(key: "\(self.title)_timeZones", defaultValue: TimeZone.current.identifier)
        self.timeZones = timezonesStr.components(separatedBy: ",")
        self.timeZonesDataSource = ComboBoxStringDataSource(completions: TimeZone.knownTimeZoneIdentifiers)
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var callback: (() -> Void) = {}
    
    public func loadSettings() {
        selectedTimeZonesHandler(self.timeZones)
    }
    
    public func load(widgets: [widget_t]) {
        self.subviews.forEach{ $0.removeFromSuperview() }
        self.addArrangedSubview(self.timeZonesSelector())
    }
    
    func timeZonesSelector() -> NSView {
        let view = NSStackView()
        view.orientation = .vertical
        
        for i in 0..<timeZones.count {
            let row = NSStackView()
            row.orientation = .horizontal
            var upButton, downButton: NSButton
            if #available(macOS 11.0, *) {
                upButton = NSButton(image: NSImage(systemSymbolName: "arrow.up", accessibilityDescription: "Up")!, target: nil, action: nil)
                downButton = NSButton(image: NSImage(systemSymbolName: "arrow.down", accessibilityDescription: "Down")!, target: nil, action: nil)
            } else {
                upButton = NSButton(title: "Up", target: nil, action: nil)
                downButton = NSButton(title: "Down", target: nil, action: nil)
            }
            upButton.tag = i
            upButton.target = self
            upButton.action = #selector(self.swapTimeZoneEntriesUp)
            upButton.isEnabled = i > 0
            
            downButton.tag = i
            downButton.target = self
            downButton.action = #selector(self.swapTimeZoneEntriesDown)
            downButton.isEnabled = i < timeZones.count - 1
            row.addArrangedSubview(upButton)
            row.addArrangedSubview(downButton)
            let selector = selectSettingsRowV1(
                title: "Timezone",
                action: #selector(timeZoneChanged),
                items: TimeZone.knownTimeZoneIdentifiers,
                selected: timeZones[i])
            row.addArrangedSubview(selector)
            let removeButton = NSButton(title: "-", target: self, action: #selector(self.removeTimeZone))
            removeButton.tag = i
            removeButton.isEnabled = timeZones.count > 1
            row.addArrangedSubview(removeButton)
            view.addArrangedSubview(row)
        }
        
        let newTimeZoneView = NSStackView()
        newTimeZoneView.orientation = .horizontal
        timeZoneNameComboBox = NSComboBox(frame: NSRect.zero)
        timeZoneNameComboBox.usesDataSource = true
        timeZoneNameComboBox.dataSource = self.timeZonesDataSource
        timeZoneNameComboBox.completes = true
        newTimeZoneView.addArrangedSubview(timeZoneNameComboBox)
        let addButton = NSButton(title: "+", target: self, action: #selector(self.addTimeZone))
        newTimeZoneView.addArrangedSubview(addButton)
        view.addArrangedSubview(newTimeZoneView)
        
        return view
    }
    
    @objc private func timeZoneChanged(_ sender: NSMenuItem) {
        print("Timezone has changed!")
    }
    
    @objc private func addTimeZone() {
        if timeZoneNameComboBox == nil {
            return
        }
        let timeZoneStr = timeZoneNameComboBox.stringValue.lowercased()
        let matchingTimeZone = TimeZone.knownTimeZoneIdentifiers.first { $0.lowercased() == timeZoneStr }
        if matchingTimeZone == nil {
            return
        }
        timeZones.append(matchingTimeZone!)
        reload()
    }
    
    @objc private func swapTimeZoneEntriesUp(_ sender: NSButton) {
        let index = sender.tag
        timeZones.swapAt(index - 1, index)
        reload()
    }
    
    @objc private func swapTimeZoneEntriesDown(_ sender: NSButton) {
        let index = sender.tag
        timeZones.swapAt(index, index + 1)
        reload()
    }
    
    @objc private func removeTimeZone(_ sender: NSButton) {
        let index = sender.tag
        timeZones.remove(at: index)
        reload()
    }
    
    private func reload() {
        self.load(widgets: [])
        selectedTimeZonesHandler(self.timeZones)
    }
    
}
