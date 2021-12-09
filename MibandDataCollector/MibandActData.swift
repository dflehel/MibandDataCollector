//
//  MibandActData.swift
//  Mi-Band for Swift
//
//  Created by Lehel Dénes-Fazakas on 2021. 11. 26..
//  Copyright © 2021. zero2one. All rights reserved.
//

import Foundation


class MibandActData{
    
    public var timestamp:Int64?
    public var userid:String?
    public var sensor:String?
    public var value:String?
    public var steps:Int?
    public var cal:Int?
    public var dis:Int?
    
    public init(){
        timestamp = 0
        userid = ""
        sensor = ""
        value = ""
        steps = 0
        cal = 0
        dis = 0
    }
    
    public func generatevalue()->String{
        self.value = "Setps=\(self.steps!) \n distance=\(self.dis!) \n calories=\(self.cal!)"
        return self.value!
    }
    
}
