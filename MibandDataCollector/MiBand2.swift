//
//  MiBand2.swift
//  Mi-Band for Swift
//
//  Created by Daniel Weber on 29.07.17.
//  Copyright © 2017 zero2one. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit
import Firebase

class MiBand2{
    
    var firststart: Bool = true
    let peripheral: CBPeripheral
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var jelzesek = [75:true,50:true,25:true]
    
    init(_ peripheral: CBPeripheral){
        self.peripheral = peripheral
    }
    
    func startVibrate(){
        vibrationAction(MiBand2Service.ALERT_LEVEL_VIBRATE_ONLY)
    }
    
    func stopVibrate(){
        vibrationAction(MiBand2Service.ALERT_LEVEL_NONE)
    }
    
    func vibrationAction(_ alert: [Int8]){
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_ALERT}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_VIBRATION_CONTROL}){
            var vibrationType = alert
            let data = NSData(bytes: &vibrationType, length: vibrationType.count)
            peripheral.writeValue(data as Data, for: characteristic, type: .withoutResponse)
        }
    }
     
    func getBattery(batteryData:Data) -> Int{
       // print("--- UPDATING Battery Data..")
       // self.startVibrate()
        var buffer = [UInt8](batteryData)
        print("\(buffer[1]) % charged")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let vc = appDelegate.window!.rootViewController as? ViewController{
            vc.batarrylabel.text = String(Int(buffer[1]))
        }
        let baterry = Int(buffer[1])
        if baterry < 75 && self.jelzesek[75] == true{
            appDelegate.updateBattery(Int(buffer[1]))
            self.jelzesek[75] = false
        }
        else {
            if baterry < 50 && self.jelzesek[50] == true{
                appDelegate.updateBattery(Int(buffer[1]))
                self.jelzesek[50] = false
            }
            else{
                if baterry < 25 && self.jelzesek[25] == true{
                    appDelegate.updateBattery(Int(buffer[1]))
                    self.jelzesek[25] = false
                }
                else {
                    if baterry%10 == 0{
                        appDelegate.updateBattery(Int(buffer[1]))
                    }
                }
                if baterry > 25 && self.jelzesek[25] == false{
                    self.jelzesek[25] = true
                }
            }
            if baterry > 50 && self.jelzesek[50] == false{
                self.jelzesek[50] = true
            }
            if baterry > 75 && self.jelzesek[75] == false{
                self.jelzesek[75] = true
            }
        }
        appDelegate.updateBattery(Int(buffer[1]))
        return Int(buffer[1])
    }
    
    
    func getSteps()->(Int, Int, Int)?{
       // startVibrate()
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE}), let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_7_REALTIME_STEPS}), let data = characteristic.value{
          //  print("--- UPDATING Steps ..")
            var buffer = [UInt8](data)
            data.copyBytes(to: &buffer, count: buffer.count)
            
            let steps = (UInt16(buffer[1] & 255) | (UInt16(buffer[2] & 255) << 8))
            let distance = (((UInt32(buffer[5] & 255) | (UInt32(buffer[6] & 255) << 8)) | UInt32(buffer[7] & 255)) | (UInt32(buffer[8] & 255) << 24));
            let calories = (((UInt32(buffer[9] & 255) | (UInt32(buffer[10] & 255) << 8)) | UInt32(buffer[11] & 255)) | (UInt32(buffer[12] & 255) << 24));
            
            let now = Date()
            var millisecondsSince1970:Int64 {
                    return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
                }
            AppDelegate.actdata.utolsoelem?.timestamp = millisecondsSince1970
            AppDelegate.actdata.utolsoelem?.sensor = "activity"
            AppDelegate.actdata.utolsoelem?.userid = "lehel"
            AppDelegate.actdata.utolsoelem?.dis = Int.init(distance)
            AppDelegate.actdata.utolsoelem?.steps = Int.init(steps)
            AppDelegate.actdata.utolsoelem?.cal = Int.init(calories)
          //  print("jottem")
          //  print(AppDelegate.actdata.utolsoelem?.steps)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let vc = appDelegate.window!.rootViewController as? ViewController{
                
                
                vc.activitylabel.text = "\(AppDelegate.actdata.utolsoelem!.generatevalue())"
                
           
            }
            return (Int.init(steps), Int.init(distance), Int.init(calories))
        }else{
            print("Characteristic or Service could nit be found")
            return nil
        }
    }
    
    func measureHeartRate(){
        if let service = peripheral.services?.first(where: {$0.uuid == MiBand2Service.UUID_SERVICE_HEART_RATE}),
            let characteristic = service.characteristics?.first(where: {$0.uuid == MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_CONTROL}){
            let data = NSData(bytes: MiBand2Service.COMMAND_START_HEART_RATE_MEASUREMENT, length: MiBand2Service.COMMAND_START_HEART_RATE_MEASUREMENT.count)
            peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
        }
        
    }
    
    
    
    func getHeartRate(heartRateData:Data) -> Int{
        //print("--- UPDATING Heart Rate..")
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let vc = appDelegate.window!.rootViewController as? ViewController{
                vc.hrlabel.text = "Hr:" + String(actualBpm)
            }
            let now = Date()
            var millisecondsSince1970:Int64 {
                    return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
                }
            AppDelegate.hrdata.addhrelemen(hrelement: MibandDatahr(timestamp:millisecondsSince1970 , userid: Auth.auth().currentUser?.uid ?? "", value:String(Int(actualBpm)) ))
//            let mibanddata = MiBandData(context: self.context)
//            mibanddata.sensor = "hr"
//            mibanddata.userid = "lehel"
//            mibanddata.value = String(Int(actualBpm))
//            mibanddata.timestamp = millisecondsSince1970
//            do {
//                try self.context.save()
//                print("mentes sikeres")
//            }catch {
//                 print(error)
//            }
            if firststart {
                AppDelegate.hrdata.sethrdata(mibanddata: MibandDatahr(timestamp:millisecondsSince1970 , userid: Auth.auth().currentUser?.uid ?? "", value:String(Int(actualBpm))))

                if let vc = appDelegate.window!.rootViewController as? ViewController{
                    let currentTime = Date()
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    vc.aggregatehr.text = "\(formatter.string(from: currentTime)) \n \(AppDelegate.hrdata.gethrdata().getvalue())"
                                             }
                firststart = false
            }
            return Int(actualBpm)
        }else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let vc = appDelegate.window!.rootViewController as? ViewController{
                vc.hrlabel.text = "Hr:" + String(Int(bpm ?? 0))
            }
            let now = Date()
            var millisecondsSince1970:Int64 {
                    return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
                }
            AppDelegate.hrdata.addhrelemen(hrelement: MibandDatahr(timestamp:millisecondsSince1970 , userid: Auth.auth().currentUser?.uid ?? "", value:String(Int(bpm ?? 0)) ))
//            let mibanddata = MiBandData(context: self.context)
//            mibanddata.sensor = "hr"
//            mibanddata.userid = "lehel"
//            mibanddata.value = String(Int(bpm!))
//            mibanddata.timestamp = millisecondsSince1970
//            do {
//                try self.context.save()
//                print("mentes sikeres")
//            }catch {
//                 print(error)
//            }
            if firststart {
                AppDelegate.hrdata.sethrdata(mibanddata: MibandDatahr(timestamp:millisecondsSince1970 , userid: Auth.auth().currentUser?.uid ?? "", value:String(Int(bpm ?? 0))))
                    }
            if let vc = appDelegate.window!.rootViewController as? ViewController{
                let currentTime = Date()
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                vc.aggregatehr.text = "\(formatter.string(from: currentTime)) \n  \(AppDelegate.hrdata.gethrdata().getvalue())"
                                         }
            firststart = false
            return Int(bpm ?? 0)
        }
    }
}
