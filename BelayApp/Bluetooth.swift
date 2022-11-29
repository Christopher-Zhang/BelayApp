//
//  Bluetooth.swift
//  BelayApp
//
//  Created by Christopher Zhang on 11/13/22.
//

import Foundation
import CoreBluetooth

class BLEController: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var bluetoothIsOn = false
    @Published var belayMessage = "climb"
    @Published var belayVoltage = 0.0
    @Published var isConnected = false
    
    var centralManager: CBCentralManager!
    var serviceUUID = CBUUID(string: "1dd5ca59-fdf9-4c64-9102-ac29090eb19e")
    var charUUID = CBUUID(string: "62516736-8bc6-45ad-9b0f-9a73e0b2d155")
    var belayDevice: CBPeripheral!
    var belayDeviceDelegate: CBPeripheralDelegate!
    var belayCharacteristic: CBCharacteristic!
    var numDevices = 0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connectPeripheral() {
        if isConnected {
            print("Device already connected!")
            return
        }
        print("connecting to peripherals")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                print("Bluetooth powered off.")
            case .poweredOn:
                print("Bluetooth powered on.")
                // start scanning
                bluetoothIsOn = true
            case .unsupported:
                print("Bluetooth is unauthorized")
            case.unknown:
                print("Unknown")
            case.resetting:
                print("Resetting Bluetooth")
            default:
                print("Unknown error in Bluetooth")
        }
    }
    
    func writeToBelayDevice(_ message: String) {
        print("Writing \"\(message)\" to belay device")
        guard let data = message.data(using: .utf8) else {
            return
        }
        belayMessage = message
        belayDevice?.writeValue(data, for: belayCharacteristic, type: .withoutResponse)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral \(numDevices) name \(peripheral.name ?? "Unknown")")
        numDevices += 1
        if peripheral.name != "ESP32test" {
            return
        }
        belayDevice = peripheral
        belayDeviceDelegate = self
        print("Found peripheral \(peripheral.name ?? "unknown device")")
        print("Connecting to \(peripheral.name ?? "unknown device")...")
        centralManager.connect(belayDevice, options: nil)
        centralManager.stopScan()
        
    }
    
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.services == nil {
            print("No services found for peripheral \(peripheral.name ?? "Unknown")")
            return
        }
        discoverCharacteristics(peripheral: peripheral)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected to \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        isConnected = true
        belayDevice.discoverServices([serviceUUID])
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        if let error = error {
            // Handle error
            print(error)
            return
        }
        // Successfully disconnected
        print("disconnected from device")
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown")")
        print(error.debugDescription)
    }
    
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("Failed to connect")
//        print(error.debugDescription)
//    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics{
            belayCharacteristic = characteristic
            belayDevice.setNotifyValue(true, for: characteristic)
        }
    }
    
    // handle value reading
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if  error != nil {
            // Handle error
            print("Error in retrieving value")
            return
        }
        
        guard let value = characteristic.value else {
            print("Invalid value")
            return
        }
        
        // TODO parse value
        let message = value.base64EncodedString()
        if let dmessage = Double(message) {
            belayVoltage = dmessage
        }
        else {
            belayMessage = message
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            // Handle error
            print("Error writing value")
            print(error.debugDescription)
            return
        }
    }
}

