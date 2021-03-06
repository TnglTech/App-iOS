//
//  DeviceManager.swift
//  MoonLamp
//

import Foundation
import CoreBluetooth

class DeviceManager: NSObject, ObservableObject {
    @Published var isScanning = true
    
    var foundDevices: [String: [Device]] {
        var dict = [String: [Device]]()
        for key in devices.keys {
            if (devices[key] != nil) {
                dict[key] = Array(devices[key]!.values)
            }
        }
        return dict
    }
    
    private var devices = [
        "moonlamps": [String: Device]()//,
//        "doorbells": [String: Device]()
    ]
    
    func findDevice(name: String) -> Device? {
        for key in devices.keys {
            if (devices[key]![name] != nil) {
                return devices[key]![name]
            }
        }
        return nil
    }
    
    private func anyDevicesFound() -> Bool {
        for key in devices.keys {
            if (!devices[key]!.isEmpty) {
                return true
            }
        }
        return false
    }
    
    private func allDevices() -> [Device] {
        var devs = [Device]()
        for key in devices.keys {
            if (devices[key] != nil) {
                devs += Array(devices[key]!.values)
            }
        }
        return devs
    }
    
    private var bluetoothManager: CBCentralManager!

    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func refresh() {
        for device in allDevices() {
            device.refresh()
        }
    }
}

extension DeviceManager: CBCentralManagerDelegate {
    func scanForDevices() {
        if bluetoothManager.state == .poweredOn {
            isScanning = true
            print("Scanning for Devices")
            bluetoothManager.scanForPeripherals(withServices: [DeviceInfoService.SERVICE_UUID])
            scheduleStopScan()
        }
    }

    private func scheduleStopScan() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            if (self?.anyDevicesFound() ?? false) {
                self?.bluetoothManager.stopScan()
                self?.isScanning = false
            } else {
                print("Still scanning for devices")
                self?.scheduleStopScan()
            }
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        scanForDevices()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if let peripheralName = peripheral.name {
            print("Manager found device: \(peripheralName)")
            
            if peripheralName.lowercased().contains("moonlamp") {
                let lamp = MoonLamp(devicePeripheral: peripheral)
                devices["moonlamps"]![peripheralName] = lamp
            } else {
                return
            }
            
            bluetoothManager.connect(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Manager Connected to peripheral \(peripheral)")
        peripheral.discoverServices([RGBLampService.SERVICE_UUID, WifiService.SERVICE_UUID, AssociationService.SERVICE_UUID, UtilityService.SERVICE_UUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let peripheralName = peripheral.name {
            if let device = findDevice(name: peripheralName) {
                print("Manager Disconnected from peripheral \(peripheral)")

                device.managerConnected = false
                bluetoothManager.connect(peripheral)
           }
        }
    }
}

