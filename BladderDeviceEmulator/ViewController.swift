//
//  ViewController.swift
//  BladderDeviceEmulator
//
//  Created by Peter Slavich on 4/17/18.
//  Copyright © 2018 Peter Slavich. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    

    
    var peripheralManager : CBPeripheralManager? = nil
    
    let bladderVolumeServiceUUID = CBUUID(string: "00000000-7E10-41C1-B16F-4430B506CDE7")
    
    let sensorArrayCharacteristicUUID = CBUUID(string: "00000001-7E10-41C1-B16F-4430B506CDE7")
    let led1CharacteristicUUID = CBUUID(string: "00000001-6E10-41C1-B16F-4430B506CDE7")
    let led2CharacteristicUUID = CBUUID(string: "00000002-6E10-41C1-B16F-4430B506CDE7")
    let led3CharacteristicUUID = CBUUID(string: "00000003-6E10-41C1-B16F-4430B506CDE7")
    let led4CharacteristicUUID = CBUUID(string: "00000004-6E10-41C1-B16F-4430B506CDE7")
    let led5CharacteristicUUID = CBUUID(string: "00000005-6E10-41C1-B16F-4430B506CDE7")
    let led6CharacteristicUUID = CBUUID(string: "00000006-6E10-41C1-B16F-4430B506CDE7")
    let led7CharacteristicUUID = CBUUID(string: "00000007-6E10-41C1-B16F-4430B506CDE7")
    let led8CharacteristicUUID = CBUUID(string: "00000008-6E10-41C1-B16F-4430B506CDE7")

    var ledCharacteristics = [CBMutableCharacteristic]()
    
    var sensorArrayCharacteristic : CBMutableCharacteristic? = nil
    var led1Characteristic : CBMutableCharacteristic? = nil
    var led2Characteristic : CBMutableCharacteristic? = nil
    var led3Characteristic : CBMutableCharacteristic? = nil
    var led4Characteristic : CBMutableCharacteristic? = nil
    var led5Characteristic : CBMutableCharacteristic? = nil
    var led6Characteristic : CBMutableCharacteristic? = nil
    var led7Characteristic : CBMutableCharacteristic? = nil
    var led8Characteristic : CBMutableCharacteristic? = nil

    var bladderVolumeService : CBMutableService? = nil
    
    var sensorReadings : [UInt32]? = nil
    var sensorReadingData : Data? = nil
    
    var centralIsSubscribed : Bool = false
    var channelIsFull : Bool = false
    
    var timer : Timer? = nil
    var ledIndex : Int = 0
    
    @IBOutlet weak var textField: UITextView!
    
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Manager updated state: \(peripheral.state.rawValue)")
        textField.text.append("Manager updated state:")

        if (peripheral.state == .poweredOn) {
            textField.text.append(" poweredOn\n")
            setupServices()
        }
        else {
            textField.text.append(" other than poweredOn\n")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error == nil {
            print("service added:" + service.description)
            textField.text.append("Bladder service added\n")
            startAdvertising()
        }
        else if let e = error {
            print ("error adding service " + e.localizedDescription)
            textField.text.append("Error adding service " + e.localizedDescription + "\n")

        }
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error == nil {
            print("advertising begun")
            textField.text.append("Advertising begun\n")
        }
        else if let e = error {
            print ("error advertising")
            textField.text.append("Error advertising: " + e.localizedDescription + "\n")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid == sensorArrayCharacteristicUUID {
//            if request.offset > sensorArrayCharacteristic!.value!.count {
//                peripheralManager?.respond(to: request, withResult: .invalidOffset)
//                print ("invalid offset in request")
//                textField.text.append("Invalid offset in request\n")
//                return
//            }
            
            request.value = sensorReadingData!.subdata(in: request.offset..<sensorReadingData!.count)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to request\n")
        }
        else if request.characteristic.uuid == led1CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: request.offset..<3)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led1 request\n")
        }
        else if request.characteristic.uuid == led2CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+3)..<6)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led2 request\n")
        }
        else if request.characteristic.uuid == led3CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+6)..<9)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led3 request\n")
        }
        else if request.characteristic.uuid == led4CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+9)..<12)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led4 request\n")
        }
        else if request.characteristic.uuid == led5CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+12)..<15)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led5 request\n")
        }
        else if request.characteristic.uuid == led6CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+15)..<18)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led6 request\n")
        }
        else if request.characteristic.uuid == led7CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+18)..<21)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led7 request\n")
        }
        else if request.characteristic.uuid == led8CharacteristicUUID {
            request.value = sensorReadingData!.subdata(in: (request.offset+21)..<24)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to led8 request\n")
        }
        else
        {
            peripheralManager?.respond(to: request, withResult: .attributeNotFound)
            print ("invalid characteristic in request")
            textField.text.append("Invalid characteristic in request\n")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        if !centralIsSubscribed {
            centralIsSubscribed = true
            startMeasuring()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        if centralIsSubscribed {
            centralIsSubscribed = false
            stopMeasuring()
        }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        let data = sensorReadingData!.subdata(in: ((ledIndex - 1)*3)..<(ledIndex * 3))
        let success = peripheralManager!.updateValue(data, for: ledCharacteristics[ledIndex-1], onSubscribedCentrals: nil)
        if success {
            ledIndex = (ledIndex % 8) + 1
            channelIsFull = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        populateReadings()
//        createReadingsBytes()
        startupBluetooth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startupBluetooth() {
        print ("Attempting to start up bluetooth manager...")
        textField.text.append("Attempting to start up bluetooth manager...\n")
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func setupServices() {
        print ("Attempting to set up services...")
        textField.text.append("Attempting to set up services...\n")
        
        bladderVolumeService = CBMutableService(type: bladderVolumeServiceUUID, primary: true)
        sensorArrayCharacteristic = CBMutableCharacteristic(type: sensorArrayCharacteristicUUID, properties: CBCharacteristicProperties([.read]), value: nil, permissions: CBAttributePermissions([.readable]))
        led1Characteristic = CBMutableCharacteristic(type: led1CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led2Characteristic = CBMutableCharacteristic(type: led2CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led3Characteristic = CBMutableCharacteristic(type: led3CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led4Characteristic = CBMutableCharacteristic(type: led4CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led5Characteristic = CBMutableCharacteristic(type: led5CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led6Characteristic = CBMutableCharacteristic(type: led6CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led7Characteristic = CBMutableCharacteristic(type: led7CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))
        led8Characteristic = CBMutableCharacteristic(type: led8CharacteristicUUID, properties: CBCharacteristicProperties([.read, .notify]), value: nil, permissions: CBAttributePermissions([.readable]))

        ledCharacteristics = [led1Characteristic!, led2Characteristic!, led3Characteristic!, led4Characteristic!, led5Characteristic!, led6Characteristic!, led7Characteristic!, led8Characteristic!]
        bladderVolumeService!.characteristics = [sensorArrayCharacteristic!, led1Characteristic!, led2Characteristic!, led3Characteristic!, led4Characteristic!, led5Characteristic!, led6Characteristic!, led7Characteristic!, led8Characteristic!]
        peripheralManager?.add(bladderVolumeService!)
    }
    
    func startAdvertising() {
        print ("Attempting to start advertising...")
        textField.text.append("Attempting to start advertising...\n")
        
        peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [bladderVolumeServiceUUID]])
    }

    func populateReadings() {
        sensorReadings = [UInt32]()
        for _ in 1...64 {
            sensorReadings?.append(arc4random_uniform(1048576))
        }
        
        for i in 0...7 {
            textField.text.append("LED \(i+1): ")
            for j in 0...7 {
                textField.text.append("\(sensorReadings![8*i + j]) ")
                if (j + 1) % 4 == 0 {
                    textField.text.append("\n")
                }
            }
        }
    }
    
    func createReadingsBytes() {
        sensorReadingData = Data()
        for i in 1...64 {
            var n = sensorReadings?[i-1]
            let d = Data(buffer: UnsafeBufferPointer(start: &n, count: 1))
            let data = d.subdata(in: 0..<3)
            //print (n!)
            //print(data as NSData)
            //print(d.subdata(in: 0..<1) as NSData)
            
            sensorReadingData?.append(data)
        }
        print(sensorReadingData!.count)
        print(sensorReadingData! as NSData)
    }
    
    @objc func sendSensorArray() {
        if !channelIsFull {
            if ledIndex == 1 {
                populateReadings()
                createReadingsBytes()
            }
            let data = sensorReadingData!.subdata(in: ((ledIndex - 1)*24)..<(ledIndex * 24))
            let success = peripheralManager!.updateValue(data, for: ledCharacteristics[ledIndex-1], onSubscribedCentrals: nil)
            if success {
                ledIndex = (ledIndex % 8) + 1
            }
            else {
                channelIsFull = true
            }

            
        }
    }
    
    func startMeasuring() {
        ledIndex = 1
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(sendSensorArray), userInfo: nil, repeats: true)

    }
    
    func stopMeasuring() {
        timer?.invalidate()
    }
    
}

