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
    
    var sensorArrayCharacteristic : CBCharacteristic? = nil
    var bladderVolumeService : CBService? = nil
    
    var sensorReadings : [UInt32]? = nil
    var sensorReadingData : Data? = nil
    
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
            
            request.value = sensorReadingData!.subdata(in: request.offset..<sensorReadingData!.count-request.offset)
            peripheralManager?.respond(to: request, withResult: .success)
            print ("responded to request")
            textField.text.append("Responded to request\n")
            
        }
        else
        {
            peripheralManager?.respond(to: request, withResult: .attributeNotFound)
            print ("invalid characteristic in request")
            textField.text.append("Invalid characteristic in request\n")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        populateReadings()
        createReadingsBytes()
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
        
        let bladderVolumeService = CBMutableService(type: bladderVolumeServiceUUID, primary: true)
        sensorArrayCharacteristic = CBMutableCharacteristic(type: sensorArrayCharacteristicUUID, properties: CBCharacteristicProperties([.read]), value: nil, permissions: CBAttributePermissions([.readable]))
        
        bladderVolumeService.characteristics = [sensorArrayCharacteristic!]
        peripheralManager?.add(bladderVolumeService)
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
        
        for i in 0...63 {
            textField.text.append("\(sensorReadings![i]) ")
            if (i + 1) % 4 == 0 {
                textField.text.append("\n")
            }
        }
    }
    
    func createReadingsBytes() {
        sensorReadingData = Data()
        for i in 1...64 {
            var n = sensorReadings?[i-1]
            let d = Data(buffer: UnsafeBufferPointer(start: &n, count: 1))
            let data = d.subdata(in: 0..<3)
            print (n!)
            print(data as NSData)
            print(d.subdata(in: 0..<1) as NSData)
            
            sensorReadingData?.append(data)
        }
        print(sensorReadingData!.count)
        print(sensorReadingData! as NSData)
    }
}

