//
//  WifiState.swift
//  MoonLamp
//
//  Created by Christian Tingle on 4/9/22.
//

import Foundation

struct WifiState: ServiceState, Equatable {
    var ssid = ""
    var psk = ""
    var wifiResponse = ""
}
