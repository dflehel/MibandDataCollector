//
//  ViewController.swift
//  MibandDataCollector
//
//  Created by Lehel Dénes-Fazakas on 2021. 12. 06..
//

import UIKit
import Firebase


class ViewController: UIViewController {
    var currentTime: Date?
  
    @IBOutlet weak var aggregatehr: UILabel!
    @IBOutlet weak var activitylabel: UILabel!
    @IBOutlet weak var batarrylabel: UILabel!
    @IBOutlet weak var hrlabel: UILabel!
    @IBOutlet weak var statuslabel: UILabel!
    @IBOutlet weak var mibandconnectionlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Messaging.messaging().subscribe(toTopic: "rendszeruzenet") { error in
              print("Subscribed to weather topic")
            }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func outlog(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let delegetem = (UIApplication.shared.delegate as? AppDelegate)
            delegetem?.centralManager.cancelPeripheralConnection((delegetem?.miBand.peripheral)!)
            let vc = delegetem?.window?.rootViewController as? ViewController
            vc?.mibandconnectionlabel.text = "Miband Disconected"
            vc?.statuslabel.text = "Az alkalmazás nem működik: kérjük regisztráljon be, vagy jelentkezzen be"
            vc?.statuslabel.textColor = .white
            vc?.statuslabel.backgroundColor = .red
            print("Success! Yum.")
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    
    
    

    
    
    func updateTime() {
      currentTime = Date()
      let formatter = DateFormatter()
      formatter.timeStyle = .short
      print("megvagyok")
      if let currentTime = currentTime {
        hrlabel.text = formatter.string(from: currentTime)
        
      }
    }
    
   
}

