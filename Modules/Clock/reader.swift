//
//  reader.swift
//  Clock
//
//  Created by Krisztián Szabó on 2022. 08. 06..
//  Copyright © 2022. Serhiy Mytrovtsiy. All rights reserved.
//

import Foundation
import Kit

internal class ClockReader: Reader<Date> {
    
    override func read() {
        self.callback(Date.init())
    }
    
    override func setup() {
        self.setInterval(1)
    }
    
}
