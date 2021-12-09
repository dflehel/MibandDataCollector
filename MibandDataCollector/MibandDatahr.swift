//
//  MibandDatahr.swift
//  datacollateorMibanIOS
//
//  Created by Lehel Dénes-Fazakas on 2021. 11. 24..
//

import Foundation


class MibandDatahr{
    private var timestamp:Int64?
    private var userid:String?
    private var sensor:String?
    private var value:String?
    
    public init(timestamp:Int64,userid:String,value:String){
        self.value = value
        self.timestamp = timestamp
        self.userid = userid
        self.sensor = "hr"
    }
    
    public init(){
        self.sensor = ""
        self.timestamp = 0
        self.userid = ""
        self.value = ""
    }
    
    public func gettimestamp() -> Int64{
        return self.timestamp ?? 0
    }
    
    public func getuserid() -> String{
        return self.userid ?? ""
    }
    
    public func getsensor() -> String{
        return self.sensor ?? ""
    }
    public func getvalue() -> String{
        return self.value ?? ""
    }
    
    public func setvalue( value:String){
        self.value = value
    }
    public func setuserid( userid:String){
        self.userid = userid
    }
    public func setsensor( sensor:String){
        self.sensor = sensor
    }
    public func settimestamp( timestamp:Int64){
        self.timestamp = timestamp
    }
    
}
