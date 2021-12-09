//
//  MibandActDataArray.swift
//  Mi-Band for Swift
//
//  Created by Lehel Dénes-Fazakas on 2021. 11. 26..
//  Copyright © 2021. zero2one. All rights reserved.
//

import Foundation


class MibandActDataArray{
    
    public var actarray:[MibandActData]?
    public var utolsoelem:MibandActData?
    
    
    public init(){
        self.actarray = []
        self.utolsoelem = MibandActData()
    }
    
    
    public func addelement(dataa:MibandActData){
        self.actarray?.append(dataa)
    }
    
    public func average()->MibandActData{
        
        var ossz1 = 0
        var ossz2 = 0
        var ossz3 = 0
        if self.actarray!.count == 0{
            return self.lastelement()
        }
        else{
        for dataa in self.actarray!{
            ossz1 = ossz1 + dataa.steps!
            ossz2 = ossz2 + dataa.cal!
            ossz3 = ossz3 + dataa.dis!
        }
        let mibandata = MibandActData()
        mibandata.sensor = "activity"
        mibandata.userid = "lehel"
        mibandata.steps = ossz1/actarray!.count
        mibandata.cal = ossz2/actarray!.count
        mibandata.dis = ossz3/actarray!.count
        mibandata.generatevalue()
        let now = Date()
        var millisecondsSince1970:Int64 {
                return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
            }
        mibandata.timestamp = millisecondsSince1970
        self.utolsoelem = mibandata
        return mibandata
        }
    }
    
    public func cleardata(){
        self.actarray?.removeAll()
    }
    
    public func lastelement()->MibandActData{
        let now = Date()
        var millisecondsSince1970:Int64 {
                return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
            }
        self.utolsoelem?.timestamp = millisecondsSince1970
        return self.utolsoelem!
    }
    
    
}
