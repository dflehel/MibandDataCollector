//
//  MibandDatahrArray.swift
//  datacollateorMibanIOS
//
//  Created by Lehel Dénes-Fazakas on 2021. 11. 24..
//

import Foundation

class MibandDatahrArray{
    private var hrarray:[MibandDatahr]?
    private var hrdata:MibandDatahr?
    
    public init(){
        self.hrarray = []
    }
    
    public init(hrarray:[MibandDatahr]){
        self.hrarray = []
    }
    
    public func addhrelemen(hrelement:MibandDatahr){
        self.hrarray?.append(hrelement)
    }
    
    public func sethrarray(hrarra:[MibandDatahr]){
        self.hrarray = hrarra
    }
    
    public func gethrarray() -> [MibandDatahr]{
        return self.hrarray ?? []
    }
    
    public func getaverage() -> MibandDatahr{
        var osszezo:Int = 0
        for hrdata in self.hrarray!{
            if hrdata.getvalue() == ""{
                osszezo = osszezo + 0
            }
            else {
                let szam = Int(hrdata.getvalue()) ?? 0
                osszezo = osszezo + Int(UInt8(szam))
            }
        }
        if self.hrarray!.count == 0{
            let now = Date()
            var millisecondsSince1970:Int64 {
                    return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
                }
            self.hrdata?.settimestamp(timestamp: millisecondsSince1970)
            return self.hrdata ?? MibandDatahr()
        }
        let oszatas:Int = Int(osszezo)/self.hrarray!.count
        let now = Date()
        var millisecondsSince1970:Int64 {
                return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
            }
        self.hrdata?.settimestamp(timestamp: millisecondsSince1970)
        self.hrdata?.setvalue(value: String(UInt8(oszatas)))
        return self.hrdata!
    }
    public func cleardata(){
        self.hrarray?.removeAll()
    }
    
    public func gethrdata()->MibandDatahr{
        return self.hrdata ?? MibandDatahr()
    }
    
    public func sethrdata(mibanddata:MibandDatahr){
        self.hrdata = mibanddata
    }
    
    public func sethrdata( hrdata:Int){
        let now = Date()
        var millisecondsSince1970:Int64 {
                return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
            }
        self.hrdata?.settimestamp( timestamp:millisecondsSince1970)
        self.hrdata?.setvalue(value: String(hrdata))
    }
}
