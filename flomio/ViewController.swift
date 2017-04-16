//
//  ViewController.swift
//  flomio
//
//  Created by KEITH BURNELL on 3/30/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FmSessionManagerDelegate {

    @IBOutlet weak var btnWriteTag: UIButton!
    @IBOutlet weak var btnReadTag: UIButton!
    @IBOutlet weak var btnCheckIn: UIButton!
    @IBOutlet weak var txtLog: UITextView!
    
    var device : FmDevice?
    var theDeviceId : String!
    let readerManager : FmSessionManager = FmSessionManager()
    
    @IBAction func btnWriteTagClick(_ sender: Any) {
        writeLog(message: "Write Tag Clicked!");
        let data = NSUUID().uuidString;
        readerManager.sendApdu(data, toDevice: theDeviceId);
        writeLog(message: "Sent APDU: \(data)")
    }
    
    @IBAction func btnReadTagClick(_ sender: Any) {
        writeLog(message: "Read Tag Clicked!");
    }
    
    @IBAction func btnCheckInClick(_ sender: Any) {
        writeLog(message: "Check In Clicked!");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        initNfcHardware();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func writeLog(message: String) {
        txtLog.text = txtLog.text + "\n" + message;
    }
    
    func didFindTag(withUuid Uuid: String!, fromDevice deviceId: String!, withAtr Atr: String!, withError error: Error!) {
        //writeLog(message: "didFindTag1");
        //theDeviceId = deviceId
        //writeLog(message: "DEVICE ID: \(theDeviceId)");
        DispatchQueue.main.async {
            if let thisUuid = Uuid {
                self.writeLog(message: "SCANNED - GUID: \(thisUuid)")
            } else {
                self.writeLog(message: "Error!")
            }
        }
    }
    
    func didFindTag(withData payload: [AnyHashable : Any]!, fromDevice deviceId: String!, withAtr Atr: String!, withError error: Error!) {
        //writeLog(message: "didFindTag2");
        DispatchQueue.main.async {
            let thisDeviceId = deviceId
            if let thisPayload = payload["Raw Data"] {
                self.writeLog(message: "Did find payload (raw): \(thisPayload) from Device: \(String(describing: thisDeviceId))")
            } else if let ndef = payload["Ndef"] {
                self.writeLog(message: "Did find payload (ndef): \(ndef) from Device: \(String(describing: thisDeviceId))")
            }
        }
    }
    
    func didUpdateConnectedDevices(_ devices: [Any]!) {
        //writeLog(message: "didUpdateConnectedDevices");
        //The list of connected devices was updated
        let fmDevices = devices as! [FmDevice]
        theDeviceId = fmDevices[0].serialNumber
    }
    
    func didChange(_ status: CardStatus, fromDevice device: String!) {
        //writeLog(message: "didChange");
        DispatchQueue.main.async {
            //The card status has entered or left the scan range of the reader
            // Cardstatus:
            // 0:CardStatus.notPresent
            // 1:CardStatus.present
            // 2:CardStatus.readingData
        }
    }
    
    func didReceiveReaderError(_ error: Error!) {
        //writeLog(message: "didReceiveReaderError");
        DispatchQueue.main.async {
            self.writeLog(message: "Error!")
        }
    }
    
    func inactive() {
        writeLog(message: "App Inactive")
    }
    
    func active() {
        writeLog(message: "App Activated")
    }
    
    func initNfcHardware() {
        readerManager.selectedDeviceType = DeviceType.flojackMsr;
        readerManager.delegate = self
        readerManager.specificDeviceId = nil;
        let configurationDictionary : [String : Any] =
            ["Scan Sound" : 1,
             "Scan Period" : 1000,
             "Reader State" : ReaderStateType.readData.hashValue, //readData for NDEF
             "Allow Multiconnect" : false
        ]
        readerManager.setConfiguration(configurationDictionary)
        readerManager.createReaders();
        writeLog(message: "NFC Hardware Initialized");
    }


}

