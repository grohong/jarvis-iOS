//
//  Device.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 16..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension ContextManager {
    func makeContext(deviceState: DeviceState) -> ContextData {
        var context = ContextData()
        context.namespace = "Device"
        context.name = "DeviceState"
        // set payload
        var payload = [String:Any]()
        payload["localTime"] = deviceState.localTime
        if deviceState.airplaneInfo != nil {
            //set airplane
            var airplane = [String:Any]()
            airplane["state"] = deviceState.airplaneInfo?.state
            airplane["actions"] = deviceState.airplaneInfo?.actions
            payload["airplane"] = airplane
        }
        if deviceState.batteryInfo != nil {
            //set battery
            var battery = [String:Any]()
            battery["actions"] = deviceState.batteryInfo?.actions
            battery["charging"] = deviceState.batteryInfo?.charging
            battery["value"] = deviceState.batteryInfo?.value
            payload["battery"] = battery
        }
        if deviceState.bluetoothInfo != nil {
            //set bluetooth
            var bluetooth = [String:Any]()
            bluetooth["state"] = deviceState.bluetoothInfo?.state
            bluetooth["actions"] = deviceState.bluetoothInfo?.actions
            var btlist = [[String:Any]]()
            for bt in (deviceState.bluetoothInfo?.btlist)! {
                var btJson = [String:Any]()
                btJson["name"] = bt.name
                btJson["address"] = bt.address
                btJson["connected"] = bt.connected
                btlist.append(btJson)
            }
            bluetooth["btlist"] = btlist
            var scanlist = [[String:Any]]()
            for scan in (deviceState.bluetoothInfo?.scanlist)! {
                var scanJson = [String:Any]()
                scanJson["name"] = scan.name
                scanJson["address"] = scan.address
                scanJson["role"] = scan.role
                scanlist.append(scanJson)
            }
            bluetooth["scanlist"] = scanlist
            payload["bluetooth"] = bluetooth
        }
        if deviceState.cellularInfo != nil {
            //set cellular
            var cellular = [String:Any]()
            cellular["state"] = deviceState.cellularInfo?.state
            cellular["actions"] = deviceState.cellularInfo?.actions
            payload["cellular"] = cellular
        }
        if deviceState.channelInfo != nil {
            //set channel
            var channel = [String:Any]()
            channel["actions"] = deviceState.channelInfo?.actions
            payload["channel"] = channel
        }
        if deviceState.energySavingModeInfo != nil {
            //set energySavingMode
            var energySavingMode = [String:Any]()
            energySavingMode["state"] = deviceState.energySavingModeInfo?.state
            energySavingMode["actions"] = deviceState.energySavingModeInfo?.actions
            payload["energySavingMode"] = energySavingMode
        }
        if deviceState.flashLightInfo != nil {
            //set flashLight
            var flashLight = [String:Any]()
            flashLight["state"] = deviceState.flashLightInfo?.state
            flashLight["actions"] = deviceState.flashLightInfo?.actions
            payload["flashLight"] = flashLight
        }
        if deviceState.gpsInfo != nil {
            //set gps
            var gps = [String:Any]()
            gps["state"] = deviceState.gpsInfo?.state
            gps["actions"] = deviceState.gpsInfo?.actions
            payload["gps"] = gps
        }
        if deviceState.powerInfo != nil {
            //set power
            var power = [String:Any]()
            power["state"] = deviceState.powerInfo?.state
            power["actions"] = deviceState.powerInfo?.actions
            payload["power"] = power
        }
        if deviceState.screenBrightnessInfo != nil {
            //set screenBrightness
            var screenBrightness = [String:Any]()
            screenBrightness["actions"] = deviceState.screenBrightnessInfo?.actions
            screenBrightness["max"] = deviceState.screenBrightnessInfo?.max
            screenBrightness["min"] = deviceState.screenBrightnessInfo?.min
            screenBrightness["value"] = deviceState.screenBrightnessInfo?.value
            payload["screenBrightness"] = screenBrightness
        }
        if deviceState.soundModeInfo != nil {
            //set soundMode
            var soundMode = [String:Any]()
            soundMode["state"] = deviceState.soundModeInfo?.state
            soundMode["actions"] = deviceState.soundModeInfo?.actions
            payload["soundMode"] = soundMode
        }
        if deviceState.soundOutputInfo != nil {
            //set soundOutput
            var soundOutput = [String:Any]()
            soundOutput["type"] = deviceState.soundOutputInfo?.type
            payload["soundOutput"] = soundOutput
        }
        if deviceState.volumeInfo != nil {
            //set volume
            var volume = [String:Any]()
            volume["actions"] = deviceState.volumeInfo?.actions
            volume["max"] = deviceState.volumeInfo?.max
            volume["min"] = deviceState.volumeInfo?.min
            volume["value"] = deviceState.volumeInfo?.value
            volume["warning"] = deviceState.volumeInfo?.warning
            payload["volume"] = volume
        }
        if deviceState.wifiInfo != nil {
            //set wifi
            var wifi = [String:Any]()
            wifi["state"] = deviceState.wifiInfo?.state
            wifi["actions"] = deviceState.wifiInfo?.actions
            var networks = [[String:Any]]()
            for network in (deviceState.wifiInfo?.networks)! {
                var networkJson = [String:Any]()
                networkJson["name"] = network.name
                networkJson["connected"] = network.connected
                networks.append(networkJson)
            }
            wifi["networks"] = networks
            payload["wifi"] = wifi
        }
        
        context.payload = payload
        return context
    }
    
    struct DeviceState {
        var airplaneInfo: AirplaneInfo?
        var batteryInfo: BatteryInfo?
        var bluetoothInfo: BluetoothInfo?
        var cellularInfo: CellularInfo?
        var channelInfo: ChannelInfo?
        var energySavingModeInfo: EnergySavingModeInfo?
        var flashLightInfo: FlashLightInfo?
        var gpsInfo: GPSInfo?
        var localTime: String?
        var powerInfo: PowerInfo?
        var screenBrightnessInfo: ScreenBrightnessInfo?
        var soundModeInfo: SoundModeInfo?
        var soundOutputInfo: SoundOutputInfo?
        var volumeInfo: VolumeInfo?
        var wifiInfo: WifiInfo?
    }
    
    struct AirplaneInfo {
        var actions: [String]
        var state: String
    }
    
    struct BatteryInfo {
        var actions: [String]
        var value: Int
        var charging: Bool
    }
    
    struct BluetoothInfo {
        var actions: [String]
        var btlist: [BTlist]
        var scanlist: [ScanList]
        var state: String
    }
    
    struct BTlist {
        var name: String
        var address: String
        var connected: Bool
    }
    
    struct ScanList {
        var name: String
        var address: String
        var role: String
    }
    
    struct CellularInfo {
        var actions: [String]
        var state: String
    }
    
    struct ChannelInfo {
        var actions: [String]
    }
    
    struct EnergySavingModeInfo {
        var actions: [String]
        var state: String
    }
    
    struct FlashLightInfo {
        var actions: [String]
        var state: String
    }
    
    struct GPSInfo {
        var actions: [String]
        var state: String
    }
    
    struct PowerInfo {
        var actions: [String]
        var state: String
    }
    
    struct ScreenBrightnessInfo {
        var actions: [String]
        var min: Int
        var max: Int
        var value: Int
    }
    
    struct SoundModeInfo {
        var actions: [String]
        var state: String
    }
    
    struct SoundOutputInfo {
        var type: String
    }
    
    struct VolumeInfo {
        var actions: [String]
        var min: Int
        var max: Int
        var warning: Int?
        var value: Int
    }
    
    struct WifiInfo {
        var actions: [String]
        var networks: [Network]
        var state: String
    }
    
    struct Network {
        var name: String
        var connected: Bool
    }
    
    func makeContext(display: Display) -> ContextData {
        var displayContext = ContextData()
        displayContext.namespace = "Device"
        displayContext.name = "Display"
        
        // set payload
        var payload = [String:Any]()
        payload["size"] = display.size.rawValue
        payload["dpi"] = display.dpi
        payload["orientation"] = display.orientation?.rawValue
        if display.contentLayer != nil {
            //set contentLayer
            var contentLayer = [String:Any]()
            contentLayer["width"] = display.contentLayer?.width
            contentLayer["height"] = display.contentLayer?.height
            payload["contentLayer"] = contentLayer
        }
        
        displayContext.payload = payload
        return displayContext
    }
    
    struct Display {
        var contentLayer: ContentLayer?
        var dpi: Int?
        var orientation: Orientation?
        var size: Size = Size.custom
    }
    
    struct ContentLayer {
        var width: Int
        var height: Int
    }
    
    enum Orientation: String {
        case landscape = "landscape"
        case portrait = "portrait"
    }
    
    enum Size: String {
        case none = "none"
        case s100 = "s100"
        case m100 = "m100"
        case l100 = "l100"
        case xl100 = "xl100"
        case custom = "custom"
    }
}

/*
 {
     "header": {
         "namespace": "Device",
         "name": "DeviceState"
     },
     "payload": {
         "airplane": {{AirplaneInfoObject}},
         "battery": {{BatteryInfoObject}},
         "bluetooth": {{BluetoothInfoObject}},
         "cellular": {{CellularInfoObject}},
         "channel": {{ChannelInfoObject}},
         "energySavingMode": {{EnergySavingModeInfoObject}},
         "flashLight" {{FlashLightInfoObject}},
         "gps": {{GPSInfoObject}},
         "localTime": {{string}},
         "power": {{{PowerInforObject}},
         "screenBrightness": {{ScreenBrightnessInfoObject}},
         "soundMode": {{SoundModeInfoObject}},
         "soundOutput": {{SoundOutputInfoObject}},
         "volume": {{VolumeInfoObject}},
         "wifi": {{WifiInfoObject}}
     }
 }
 */

/*
 {
     "header": {
         "namespace": "Device",
         "name": "Display"
     },
     "payload": {
         "contentLayer": {
             "width": {{number}},
             "height": {{number}}
         },
         "dpi": {{number}},
         "orientation": {{string}},
         "size": {{string}}
     }
 }
 */
